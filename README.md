
# 🏠 Supply Chain Analytics dbt+snowflake project 2026

## 📋 Overview

This project implements a complete end-to-end data engineering pipeline for Supply Chain Analytics 2026 data using modern cloud technologies. The solution demonstrates best practices in data warehousing, transformation, and analytics using **Snowflake**, **dbt (Data Build Tool)**, and **Azure**.

The pipeline processes customers, line_items, orders, nations, regions, parts, part_suppliers and suppliers data through a medallion architecture (Bronze → Silver → Gold), implementing incremental loading, slowly changing dimensions (SCD Type 2), and creating analytics-ready datasets.

## 🏗️ Architecture

### Data Flow
```
Source Data (CSV) → Azure ADLS Gen2 → Snowflake (Staging) → Bronze Layer → Silver Layer → Gold Layer
                                                           ↓              ↓           ↓
                                                      Raw Tables    Cleaned Data   Analytics
```

### Technology Stack

- **Cloud Data Warehouse**: Snowflake
- **Transformation Layer**: dbt (Data Build Tool)
- **Cloud Storage**: Azure ADLS Gen2 (implied)
- **Version Control**: Git
- **Python**: 3.12+
- **Key dbt Features**:
  - Incremental models
  - Snapshots (SCD Type 2)
  - Custom macros
  - Jinja templating
  - Testing and documentation

## 📊 Data Model

### Medallion Architecture

#### 🥉 Bronze Layer (Raw Data)
Raw data ingested from staging with minimal transformations:
- `bronze_customers` - Raw customers
- `bronze_line_items` - Raw line_items
- `bronze_orders` - Raw orders
- `bronze_nations` - Raw nations
- `bronze_regions` - Raw regions
- `bronze_parts` - Raw parts
- `bronze_part_suppliers` - Raw part_suppliers
- `bronze_suppliers` - Raw suppliers


#### 🥈 Silver Layer (Cleaned Data)
Cleaned and standardized data:
- `silver_customers__with_geography` -  
- `silver_suppliers__with_geography` -  
- `silver_orders__enriched` -  
- `line_items__enriched` -
- `order_items__aggregated` -

#### 🥇 Gold Layer (Analytics-Ready)
Business-ready datasets optimized for analytics:
- `dim_suppliers` -  
-  `dim_customers` -
-  `dim_parts` -
-  `dim_dates` -
-  `fct_orders` -
-  `fct_line_items` -
-  `finance__revenue_by_segment` -
-  `finance__order_profitability` -
-  `supply_chain__supplier_performance` -
-  `supply_chain__inventory_coverage` -

### Snapshots (SCD Type 2)
Slowly Changing Dimensions to track historical changes:
- `snap_customers` - Historical customer changes
- `snap_suppliers` - Historical supplier profile changes
- `snap_part_supplier_costs` - Historical supplier parts changes

## 📁 Project Structure

```
supply_chain_analytics/
├── dbt_project.yml                          # Project config, schema routing, materializations
├── packages.yml                             # dbt_utils, dbt_expectations, audit_helper, codegen
├── profiles.yml                             # dev / ci / prod Snowflake targets
│
├── models/
│   ├── staging/
│   │   ├── _sources.yml                     # Source definitions + source tests
│   │   ├── _staging__models.yml             # Staging column tests
│   │   ├── stg__customers.sql          # VIEW
│   │   ├── stg__line_items.sql         # VIEW
│   │   ├── stg__orders.sql             # VIEW
│   │   ├── stg__nations.sql            # VIEW
│   │   ├── stg__regions.sql            # VIEW
│   │   ├── stg__parts.sql              # VIEW
│   │   ├── stg__part_suppliers.sql     # VIEW
│   │   └── stg__suppliers.sql          # VIEW
│   │
│   ├── intermediate/
│   │   ├── _intermediate__models.yml
│   │   ├── int_customers__with_geography.sql     # EPHEMERAL
│   │   ├── int_suppliers__with_geography.sql     # EPHEMERAL
│   │   ├── int_orders__enriched.sql              # EPHEMERAL
│   │   ├── int_line_items__enriched.sql          # EPHEMERAL
│   │   └── int_order_items__aggregated.sql       # EPHEMERAL
│   │
│   └── marts/
│       ├── core/
│       │   ├── _core__models.yml
│       │   ├── dim_customers.sql            # TABLE
│       │   ├── dim_suppliers.sql            # TABLE
│       │   ├── dim_parts.sql                # TABLE
│       │   ├── dim_dates.sql                # TABLE (date_spine)
│       │   ├── fct_orders.sql               # INCREMENTAL — delete+insert
│       │   └── fct_line_items.sql           # INCREMENTAL — merge
│       ├── finance/
│       │   ├── _finance__models.yml
│       │   ├── finance__revenue_by_segment.sql
│       │   └── finance__order_profitability.sql
│       └── supply_chain/
│           ├── supply_chain__supplier_performance.sql
│           └── supply_chain__inventory_coverage.sql
│
├── snapshots/
│   ├── snp_customers.sql                    # SCD Type-2, check strategy
│   ├── snp_suppliers.sql                    # SCD Type-2, check strategy
│   └── snp_part_supplier_costs.sql          # SCD Type-2, check strategy
│
├── macros/
│   ├── generate_schema_name.sql             # prod vs dev schema isolation
│   ├── test_helpers.sql                     # 6 custom generic test macros
│   ├── incremental_helpers.sql              # get_max_watermark, incremental_lookback
│   ├── pivot_helpers.sql                    # pivot_revenue_by_segment, union_relations
│   ├── date_helpers.sql                     # date_trunc_to_period, fiscal_year
│   ├── safe_divide.sql
│   └── cents_to_dollars.sql
│
├── tests/
│   ├── generic/_generic_tests.yml           # Schema-level tests on mart models
│   └── singular/
│       ├── test_revenue_consistency.sql
│       ├── test_no_orphaned_line_items.sql
│       ├── test_scd2_no_overlapping_periods.sql
│       ├── test_supplier_performance_score_bounds.sql
│       └── test_date_spine_completeness.sql
│
└── analyses/
    └── tpch_q1_pricing_summary.sql          # Official supply_chain_analytics benchmark Q1
```

## 🚀 Getting Started

### Prerequisites

1. **Snowflake Account (will create one if doesn't exist)**

2. **Python Environment**
   - Python 3.12 or higher
   - pip or uv package manager

3. **Aazure ADLS Account (will create one if doesn't exist) ** (for ADLS Gen2)

### Installation

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd supply_chain_analytics
   ```

2. **Create Virtual Environment**
   ```bash
   python -m venv .venv
   .venv\Scripts\Activate.ps1  # Windows PowerShell
   # or
   source .venv/bin/activate    # Linux/Mac
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   # or using pyproject.toml
   pip install -e .
   ```

   **Core Dependencies:**
   - `dbt-core>=1.11.2`
   - `dbt-snowflake>=1.11.0`
   - `sqlfmt>=0.0.3`

4. **Configure Snowflake Connection**
   
   Create `~/.dbt/profiles.yml`:
   ```yaml
   supply_chain_analytics:
     outputs:
       dev:
         account: <your-account-identifier>
         database: analytics
         password: <your-password>
         role: ACCOUNTADMIN
         schema: dbt_schema
         threads: 4
         type: snowflake
         user: <your-username>
         warehouse: COMPUTE_WH
     target: dev
   ```

5. **Set Up Snowflake Database**
   
   Run the DDL scripts to create tables:
   ```bash
   # Execute DDL/ddl.sql in Snowflake to create staging tables
   ```

6. **Load Source Data**
   

## 🔧 Usage

### Running dbt Commands

1. **Test Connection**
   ```bash
   cd aws_dbt_snowflake_project
   dbt debug
   ```

2. **Install Dependencies**
   ```bash
   dbt deps
   ```

3. **Run All Models**
   ```bash
   dbt run
   ```

4. **Run Specific Layer**
   ```bash
   dbt run --select bronze.*      # Run bronze models only
   dbt run --select silver.*      # Run silver models only
   dbt run --select gold.*        # Run gold models only
   ```

5. **Run Tests**
   ```bash
   dbt test
   ```

6. **Run Snapshots**
   ```bash
   dbt snapshot
   ```

7. **Generate Documentation**
   ```bash
   dbt docs generate
   dbt docs serve
   ```

8. **Build Everything**
   ```bash
   dbt build  # Runs models, tests, and snapshots
   ```

## 📚 Additional Resources

- **dbt Documentation**: https://docs.getdbt.com/
- **Snowflake Documentation**: https://docs.snowflake.com/
- **dbt Best Practices**: https://docs.getdbt.com/guides/best-practices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is part of a data engineering portfolio demonstration.

## 👤 Author

**Project**: Airbnb Data Engineering Pipeline  
**Technologies**: Snowflake, dbt, AWS, Python

## 🐛 Troubleshooting

### Common Issues

1. **Connection Error**
   - Verify Snowflake credentials in `profiles.yml`
   - Check network connectivity
   - Ensure warehouse is running

2. **Compilation Error**
   - Run `dbt debug` to check configuration
   - Verify model dependencies
   - Check Jinja syntax

3. **Incremental Load Issues**
   - Run `dbt run --full-refresh` to rebuild from scratch
   - Verify source data timestamps

## 📊 Future Enhancements

- [ ] Add data quality dashboards
- [ ] Implement CI/CD pipeline
- [ ] Add more complex business metrics
- [ ] Integrate with BI tools (Tableau/Power BI)
- [ ] Add alerting and monitoring
- [ ] Implement data masking for PII
- [ ] Add more comprehensive testing suite
