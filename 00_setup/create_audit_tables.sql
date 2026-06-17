CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.churn_customers_current_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    table_name TEXT,
    operation TEXT,
    customer_id NUMERIC,
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit.log_churn_customers_current_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.churn_customers_current_audit (
            table_name,
            operation,
            customer_id,
            old_data,
            new_data,
            changed_by,
            changed_at
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP,
            NEW.customer_id,
            NULL,
            to_jsonb(NEW),
            current_user,
            CURRENT_TIMESTAMP
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.churn_customers_current_audit (
            table_name,
            operation,
            customer_id,
            old_data,
            new_data,
            changed_by,
            changed_at
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP,
            NEW.customer_id,
            to_jsonb(OLD),
            to_jsonb(NEW),
            current_user,
            CURRENT_TIMESTAMP
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.churn_customers_current_audit (
            table_name,
            operation,
            customer_id,
            old_data,
            new_data,
            changed_by,
            changed_at
        )
        VALUES (
            TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
            TG_OP,
            OLD.customer_id,
            to_jsonb(OLD),
            NULL,
            current_user,
            CURRENT_TIMESTAMP
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_churn_customers_current
ON raw.churn_customers_current;

CREATE TRIGGER trg_audit_churn_customers_current
AFTER INSERT OR UPDATE OR DELETE
ON raw.churn_customers_current
FOR EACH ROW
EXECUTE FUNCTION audit.log_churn_customers_current_changes();