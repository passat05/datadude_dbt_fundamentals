{% snapshot employees_snapshot %}
{{
    config(
      target_database='dbt-project-485520',
      target_schema='dbt_snapshot',
      alias='employees_snapshot',
      unique_key='employee_id',
      strategy='timestamp',
      updated_at='updated_at',
      snapshot_meta_column_names={
        "dbt_valid_from": "start_date",
        "dbt_valid_to": "end_date",
        "dbt_scd_id": "scd_id",
        "dbt_updated_at": "modified_date",
        "dbt_is_deleted": "is_deleted"
      },
      dbt_valid_to_current="cast('9999-01-01' as timestamp)",
      hard_deletes="new_record"
    )
}}

select * from {{ source('stroopwafel_sns', 'employees') }}
{% endsnapshot %}

