with base as (

    select *
    from {{ ref('stg_churn_customers') }}

),

deduplicated as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by customer_id
                order by loaded_at desc
            ) as row_num
        from base
    ) ranked
    where row_num = 1

),

cleaned as (

    select
        customer_id::bigint as customer_id,
        churn::int as churn,

        case
            when tenure < 0 then null
            else tenure
        end as tenure,

        lower(trim(preferred_login_device)) as preferred_login_device,

        city_tier::int as city_tier,

        case
            when warehouse_to_home < 0 then null
            else warehouse_to_home
        end as warehouse_to_home,

        lower(trim(preferred_payment_mode)) as preferred_payment_mode,

        lower(trim(gender)) as gender,

        case
            when hour_spend_on_app < 0 then null
            else hour_spend_on_app
        end as hour_spend_on_app,

        number_of_device_registered,

        lower(trim(preferred_order_cat)) as preferred_order_cat,

        satisfaction_score::int as satisfaction_score,

        lower(trim(marital_status)) as marital_status,

        number_of_address,

        complain::int as complain,

        case
            when order_amount_hike_from_last_year < 0 then null
            else order_amount_hike_from_last_year
        end as order_amount_hike_from_last_year,

        coupon_used,
        order_count,
        day_since_last_order,
        cashback_amount,

        batch_id,
        loaded_at,
        loaded_by

    from deduplicated

),

final as (

    select
        customer_id,
        churn,

        coalesce(tenure, 0) as tenure,
        preferred_login_device,
        city_tier,
        coalesce(warehouse_to_home, 0) as warehouse_to_home,
        preferred_payment_mode,
        gender,
        coalesce(hour_spend_on_app, 0) as hour_spend_on_app,
        coalesce(number_of_device_registered, 0) as number_of_device_registered,
        preferred_order_cat,
        satisfaction_score,
        marital_status,
        coalesce(number_of_address, 0) as number_of_address,
        complain,
        coalesce(order_amount_hike_from_last_year, 0) as order_amount_hike_from_last_year,
        coalesce(coupon_used, 0) as coupon_used,
        coalesce(order_count, 0) as order_count,
        coalesce(day_since_last_order, 0) as day_since_last_order,
        coalesce(cashback_amount, 0) as cashback_amount,

        case
            when tenure is null then 1
            else 0
        end as tenure_missing_flag,

        case
            when warehouse_to_home is null then 1
            else 0
        end as warehouse_to_home_missing_flag,

        case
            when hour_spend_on_app is null then 1
            else 0
        end as hour_spend_on_app_missing_flag,

        case
            when day_since_last_order is null then 1
            else 0
        end as day_since_last_order_missing_flag,

        batch_id,
        loaded_at,
        loaded_by

    from cleaned

)

select *
from final