import sys
from datetime import datetime
from pathlib import Path
from uuid import uuid4

import pandas as pd
from sqlalchemy import text

# Add 01_ingestion folder to Python path so we can import utils
sys.path.append(str(Path(__file__).resolve().parents[1]))

from utils.db_utils import get_db_engine


DATA_FILE = Path("data/raw/churn_prediction.csv")
LOADED_BY = "local_user"


COLUMN_MAPPING = {
    "CustomerID": "customer_id",
    "Churn": "churn",
    "Tenure": "tenure",
    "PreferredLoginDevice": "preferred_login_device",
    "CityTier": "city_tier",
    "WarehouseToHome": "warehouse_to_home",
    "PreferredPaymentMode": "preferred_payment_mode",
    "Gender": "gender",
    "HourSpendOnApp": "hour_spend_on_app",
    "NumberOfDeviceRegistered": "number_of_device_registered",
    "PreferedOrderCat": "preferred_order_cat",
    "SatisfactionScore": "satisfaction_score",
    "MaritalStatus": "marital_status",
    "NumberOfAddress": "number_of_address",
    "Complain": "complain",
    "OrderAmountHikeFromlastYear": "order_amount_hike_from_last_year",
    "CouponUsed": "coupon_used",
    "OrderCount": "order_count",
    "DaySinceLastOrder": "day_since_last_order",
    "CashbackAmount": "cashback_amount",
}


def load_churn_data():
    batch_id = str(uuid4())
    loaded_at = datetime.now()
    engine = get_db_engine()

    try:
        if not DATA_FILE.exists():
            raise FileNotFoundError(f"Data file not found: {DATA_FILE}")

        # Read raw CSV file
        df = pd.read_csv(DATA_FILE)
        original_row_count = len(df)

        # Remove fully empty rows, which can appear when exporting Excel files to CSV
        df = df.dropna(how="all")
        dropped_empty_rows = original_row_count - len(df)

        if df.empty:
            raise ValueError("Data file is empty after removing empty rows.")

        # Check required columns
        missing_columns = set(COLUMN_MAPPING.keys()) - set(df.columns)
        if missing_columns:
            raise ValueError(f"Missing columns in source file: {missing_columns}")

        # CustomerID and Churn are critical fields, so they cannot be null
        if df["CustomerID"].isna().any():
            raise ValueError("CustomerID contains null values after removing empty rows.")

        if df["Churn"].isna().any():
            raise ValueError("Churn contains null values after removing empty rows.")

        # Rename columns from source format to database-friendly format
        df = df.rename(columns=COLUMN_MAPPING)
        df = df[list(COLUMN_MAPPING.values())]

        # Add ingestion metadata
        df["batch_id"] = batch_id
        df["loaded_at"] = loaded_at
        df["loaded_by"] = LOADED_BY

        with engine.begin() as connection:
            # Current table keeps only the latest loaded version
            connection.execute(text("TRUNCATE TABLE raw.churn_customers_current;"))

            df.to_sql(
                name="churn_customers_current",
                con=connection,
                schema="raw",
                if_exists="append",
                index=False,
            )

            # History table keeps all loaded batches
            df.to_sql(
                name="churn_customers_history",
                con=connection,
                schema="raw",
                if_exists="append",
                index=False,
            )

            # Load log records the ingestion result
            connection.execute(
                text(
                    """
                    INSERT INTO metadata.load_log
                    (batch_id, file_name, row_count, loaded_by, loaded_at, status, error_message)
                    VALUES
                    (:batch_id, :file_name, :row_count, :loaded_by, :loaded_at, :status, :error_message)
                    """
                ),
                {
                    "batch_id": batch_id,
                    "file_name": str(DATA_FILE),
                    "row_count": len(df),
                    "loaded_by": LOADED_BY,
                    "loaded_at": loaded_at,
                    "status": "success",
                    "error_message": None,
                },
            )

        print("Data ingestion completed successfully.")
        print(f"Batch ID: {batch_id}")
        print(f"Original rows: {original_row_count}")
        print(f"Dropped empty rows: {dropped_empty_rows}")
        print(f"Rows loaded: {len(df)}")

    except Exception as error:
        with engine.begin() as connection:
            connection.execute(
                text(
                    """
                    INSERT INTO metadata.load_log
                    (batch_id, file_name, row_count, loaded_by, loaded_at, status, error_message)
                    VALUES
                    (:batch_id, :file_name, :row_count, :loaded_by, :loaded_at, :status, :error_message)
                    """
                ),
                {
                    "batch_id": batch_id,
                    "file_name": str(DATA_FILE),
                    "row_count": 0,
                    "loaded_by": LOADED_BY,
                    "loaded_at": loaded_at,
                    "status": "failed",
                    "error_message": str(error),
                },
            )

        print("Data ingestion failed.")
        print(f"Error: {error}")
        raise


if __name__ == "__main__":
    load_churn_data()