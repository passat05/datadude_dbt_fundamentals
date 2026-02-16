{{ config(materialized='ephemeral') }}

select *
from {{ ref('stg_promotions') }}
where description not in ('Test')