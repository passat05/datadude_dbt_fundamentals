{{ config(materialized='ephemeral') }}

select *
from {{ ref('stg_cdc__promotions') }}
where description not in ('Test')