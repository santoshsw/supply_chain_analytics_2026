-- ==================================================================
-- stg__suppliers.sql
-- Supplier records — ~10K rows at SF1.
-- =================================================================

with source as (

    select * from {{ source('landing', 'supplier') }}

),

renamed as (

    select
        s_suppkey                           as supplier_key,
        s_name                              as supplier_name,
        s_address                           as address,
        s_phone                             as phone_number,
        s_acctbal::number(15, 2)            as account_balance,
        s_nationkey                         as nation_key,
        s_comment                           as supplier_comment,

        -- flag suppliers with negative balances (potential bad debt)
        (s_acctbal < 0)::boolean            as has_negative_balance,

        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['s_suppkey']) }} as supplier_surrogate_key

    from source

)

select * from renamed