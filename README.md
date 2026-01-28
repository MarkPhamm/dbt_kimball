# dbt_kimball

A dbt project demonstrating Kimball dimensional modeling techniques including:

- Slowly Changing Dimensions (SCD Type 2)
- Fact tables with surrogate key relationships
- Incremental processing with snapshot dates

## Project Structure

This repository contains two dbt implementations targeting different data warehouses:

```
dbt_kimball/
├── dbt_bigquery/    # BigQuery implementation
├── dbt_duckdb/      # DuckDB implementation (local development)
└── requirements.txt
```

## Data Model

### Staging Layer

- `stg_products` - Product data with snapshot dates
- `stg_product_categories` - Product category reference data
- `stg_product_subcategories` - Product subcategory reference data
- `stg_sales` - Sales transaction data
- `stg_territories` - Sales territory reference data

### Curated Layer

- `dim_product` - Product dimension (SCD Type 2)
- `dim_territories` - Territory dimension (SCD Type 2)
- `fact_sale` - Sales fact table

## Getting Started

### Prerequisites

1. Create and activate a virtual environment:

   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

### BigQuery Setup

1. Navigate to the BigQuery project:

   ```bash
   cd dbt_bigquery
   ```

2. Update `profiles.yml` with your GCP credentials:

   ```yaml
   dbt_bigquery:
     outputs:
       my_output:
         type: bigquery
         method: service-account
         project: your-project
         dataset: your-dataset
         keyfile: /path/to/your/keyfile.json
         threads: 10
     target: my_output
   ```

3. Run dbt:

   ```bash
   dbt deps
   dbt seed
   dbt run --vars '{"process_date": "2025-08-01"}'
   ```

### DuckDB Setup (Local Development)

1. Navigate to the DuckDB project:

   ```bash
   cd dbt_duckdb
   ```

2. The `profiles.yml` is pre-configured for local development with a file-based DuckDB database.

3. Run dbt:

   ```bash
   dbt deps
   dbt seed
   dbt run --vars '{"process_date": "2025-08-01"}'
   ```

The DuckDB database file will be created at `database/dbt_kimball.duckdb`.

1. To explore your data with the DuckDB UI:

   ```bash
   duckdb -ui
   ```

   Then in the UI, go to **Attached Database** and paste the path to your database file:

   ```bash
   database/dbt_kimball.duckdb
   ```

   Here, you can query any table, fine grain`dbt model`

## Incremental Processing

To process different snapshot dates, update the `process_date` variable:

```bash
# Process first day
dbt run --vars '{"process_date": "2025-08-01"}'

# Process second day (incremental)
dbt run --vars '{"process_date": "2025-08-02"}'

# Process third day (incremental)
dbt run --vars '{"process_date": "2025-08-03"}'
```

## Key Differences Between Implementations

| Feature | BigQuery | DuckDB |
|---------|----------|--------|
| Wildcard tables | `_TABLE_SUFFIX` | UNION ALL |
| Date parsing | `PARSE_DATE()` | `strptime()::DATE` |
| Date arithmetic | `DATE_SUB(..., INTERVAL)` | `date - INTERVAL` |
| Partitioning | Supported | Not applicable |
| Incremental strategy | `insert_overwrite` | `delete+insert` |

## Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [Kimball Group](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/)
- [dbt-bigquery](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)
- [dbt-duckdb](https://github.com/duckdb/dbt-duckdb)
