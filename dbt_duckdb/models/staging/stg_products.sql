SELECT *, DATE '2025-08-01' as snapshot_date
FROM {{ source('landing', 'products_20250801') }}
UNION ALL
SELECT *, DATE '2025-08-02' as snapshot_date
FROM {{ source('landing', 'products_20250802') }}
UNION ALL
SELECT *, DATE '2025-08-03' as snapshot_date
FROM {{ source('landing', 'products_20250803') }}
