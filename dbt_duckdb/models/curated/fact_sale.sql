{% set process_date = var('process_date') %}
{{- config(
  materialized='incremental',
  incremental_strategy='delete+insert',
  unique_key='snapshot_date'
)-}}

with tmp as (
SELECT
    strptime(s.order_date, '%m/%d/%Y')::DATE as order_date,
    s.territory_key,
    s.snapshot_date,
    (s.order_quantity * p.product_price) as revenue,
    (s.order_quantity * p.product_cost) as cost,
    (s.order_quantity * p.product_price) - (s.order_quantity * p.product_cost) as profit,
    p.product_surrogate_key

FROM {{ ref("stg_sales") }} s
LEFT JOIN {{ ref("dim_product") }} p
    ON s.product_key = p.product_key
    AND s.snapshot_date between p.effective_date and p.expired_date
WHERE s.snapshot_date = '{{ process_date }}'
)

SELECT
  tmp.order_date,
  tmp.snapshot_date,
  tmp.revenue,
  tmp.cost,
  tmp.profit,
  tmp.product_surrogate_key,
  t.sales_territory_surrogate_key
FROM tmp
LEFT JOIN {{ ref("dim_territories") }} t
    ON tmp.territory_key = t.sales_territory_key
  AND tmp.snapshot_date between t.effective_date and t.expired_date
