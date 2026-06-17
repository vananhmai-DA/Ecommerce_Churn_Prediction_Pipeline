from sqlalchemy import text

from utils.db_utils import get_db_engine


def test_connection():
    engine = get_db_engine()

    with engine.connect() as connection:
        result = connection.execute(text("SELECT current_database(), current_user;"))
        row = result.fetchone()

    print("Database connection successful.")
    print(f"Current database: {row[0]}")
    print(f"Current user: {row[1]}")


if __name__ == "__main__":
    test_connection()