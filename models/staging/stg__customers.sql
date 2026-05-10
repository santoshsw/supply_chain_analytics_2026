-- =============================================================================
-- stg__customers
-- Layer   : Staging
-- Purpose : Rename, cast, and lightly clean the CUSTOMER source table.
--           One row per customer. No business logic here.
-- =============================================================================

with source as (

    select * from {{ source('landing', 'customer') }}

),

renamed as (

    select
        -- primary key
        c_custkey                                   as customer_key,

        -- descriptive attributes
        c_name                                      as customer_name,
        c_address                                   as address,
        c_phone                                     as phone_number,
        upper(trim(c_mktsegment))                   as market_segment,

        -- financials
        c_acctbal::number(15, 2)                    as account_balance,

        -- foreign keys
        c_nationkey                                 as nation_key,

        -- freeform
        c_comment                                   as customer_comment,

        -- metadata
        {{ dbt_utils.generate_surrogate_key(['c_custkey']) }} as customer_surrogate_key
    
    from source

)

select * from renamed