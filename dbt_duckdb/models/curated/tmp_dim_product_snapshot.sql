{% set process_date = var('process_date') %}
{{
    config(
        materialized='table',
    )
}}
with product as (
    SELECT
        product_key,
        product_subcategory_key,
        product_sku,
        product_name,
        product_description,
        product_price,
        product_cost,
        product_color,
        product_size,
        snapshot_date
    FROM {{ ref('stg_products') }}
    WHERE snapshot_date = '{{ process_date }}'

)
, product_subcategories as (
    SELECT
        product_subcategory_key,
        subcategory_name,
        product_category_key,
        snapshot_date
    FROM {{ ref('stg_product_subcategories') }}
    WHERE snapshot_date = '{{ process_date }}'
)
, product_categories as (
    SELECT
        product_category_key,
        category_name,
        snapshot_date
    FROM {{ ref('stg_product_categories') }}
    WHERE snapshot_date = '{{ process_date }}'
)
, source as (
    SELECT
        product_key,
        product_sku,
        product_name,
        product_description,
        product_price,
        product_cost,
        product_color,
        product_size,
        subcategory_name,
        category_name,
        snapshot_date
    FROM product
    LEFT JOIN product_subcategories USING (product_subcategory_key, snapshot_date)
    LEFT JOIN product_categories USING (product_category_key, snapshot_date)
)

SELECT * FROM source
