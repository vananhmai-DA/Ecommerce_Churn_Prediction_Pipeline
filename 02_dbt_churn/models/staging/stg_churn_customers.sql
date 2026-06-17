with source_data as (

    select
        customer_id,
        churn,
        tenure,
        preferred_login_device,
        city_tier,
        warehouse_to_home,
        preferred_payment_mode,
        gender,
        hour_spend_on_app,
        number_of_device_registered,
        preferred_order_cat,
        satisfaction_score,
        marital_status,
        number_of_address,
        complain,
        order_amount_hike_from_last_year,
        coupon_used,
        order_count,
        day_since_last_order,
        cashback_amount,
        batch_id,
        loaded_at,
        loaded_by

    from {{ source('raw', 'churn_customers_current') }}

)

select *
from source_data