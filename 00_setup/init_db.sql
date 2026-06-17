CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS raw.churn_customers_current (
    customer_id NUMERIC,
    churn NUMERIC,
    tenure NUMERIC,
    preferred_login_device TEXT,
    city_tier NUMERIC,
    warehouse_to_home NUMERIC,
    preferred_payment_mode TEXT,
    gender TEXT,
    hour_spend_on_app NUMERIC,
    number_of_device_registered NUMERIC,
    preferred_order_cat TEXT,
    satisfaction_score NUMERIC,
    marital_status TEXT,
    number_of_address NUMERIC,
    complain NUMERIC,
    order_amount_hike_from_last_year NUMERIC,
    coupon_used NUMERIC,
    order_count NUMERIC,
    day_since_last_order NUMERIC,
    cashback_amount NUMERIC,
    batch_id TEXT,
    loaded_at TIMESTAMP,
    loaded_by TEXT
);

CREATE TABLE IF NOT EXISTS raw.churn_customers_history (
    customer_id NUMERIC,
    churn NUMERIC,
    tenure NUMERIC,
    preferred_login_device TEXT,
    city_tier NUMERIC,
    warehouse_to_home NUMERIC,
    preferred_payment_mode TEXT,
    gender TEXT,
    hour_spend_on_app NUMERIC,
    number_of_device_registered NUMERIC,
    preferred_order_cat TEXT,
    satisfaction_score NUMERIC,
    marital_status TEXT,
    number_of_address NUMERIC,
    complain NUMERIC,
    order_amount_hike_from_last_year NUMERIC,
    coupon_used NUMERIC,
    order_count NUMERIC,
    day_since_last_order NUMERIC,
    cashback_amount NUMERIC,
    batch_id TEXT,
    loaded_at TIMESTAMP,
    loaded_by TEXT
);

CREATE TABLE IF NOT EXISTS metadata.load_log (
    batch_id TEXT PRIMARY KEY,
    file_name TEXT,
    row_count INTEGER,
    loaded_by TEXT,
    loaded_at TIMESTAMP,
    status TEXT,
    error_message TEXT
);