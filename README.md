# Olist E-commerce Analytics Project

A SQL portfolio project using the Brazilian Olist e-commerce dataset to explore an analytics workflow in MySQL—from database setup and data-quality checks to advanced queries and business insights.

## Project Overview

This project strengthens practical SQL skills using a relational dataset covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and product-category translations.

The work focuses on understanding the data, documenting quality issues, preparing clean analytical tables, validating transformations, and using SQL to answer marketplace and operational questions.

## Tools

- **MySQL 8.0 / MySQL Workbench** — database creation, data loading, cleaning, validation, and analysis
- **SQL** — joins, aggregations, conditional logic, subqueries, common table expressions, and window functions
- **Markdown** — project blueprint and phase reports

## Workflow

1. Database engineering and raw data ingestion
2. Database inventory and verification
3. Data profiling
4. Data-quality assessment
5. Data cleaning
6. Data validation
7. Exploratory data analysis (EDA)
8. Advanced SQL
9. Business insights
10. Final documentation and portfolio preparation

Phase-specific SQL scripts and reports are provided in the `SQL/` and `Reports/` folders. The `Documentation/` folder contains project-level documentation.

## Selected Business Findings

The Phase 9 analysis produced several notable findings:

- **Growth was volume-driven:** comparing early 2017 with early 2018, average monthly orders increased by 303.0%, while average monthly payment value increased by 271.3%. Average order value decreased by 8.5%.
- **Category value was concentrated:** the top 5 product categories accounted for 39.16% of item value, while the top 10 accounted for 62.32% cumulatively.
- **Repeat customers were few but more valuable individually:** repeat customers represented 3.12% of customers and had approximately 94.7% higher average customer value than one-time customers.
- **Late delivery was associated with weaker reviews:** reviewed late orders averaged 2.57 out of 5, compared with 4.29 for on-time orders. Negative reviews were much more common for late orders. This is an association, not proof of causation.
- **Interstate commerce was disproportionately valuable:** interstate orders represented 64.11% of orders and 69.72% of item value, with an average order item value about 28.9% higher than in-state orders.

These are headline results only. The Phase 9 report contains supporting breakdowns and additional findings on category satisfaction and seller value.

## Repository Structure

```text
Olist-Ecommerce-SQL/
├── Data/
│   ├── Raw/          # Original source CSV files
│   └── Cleaned/      # Reserved for cleaned data exports, if required
├── Database/         # Database-related assets
├── Documentation/    # Blueprint and project-level documentation
├── Images/           # Project visuals
├── Reports/          # Phase reports and findings
├── SQL/              # Phase-specific SQL scripts
└── README.md
```

The cleaning workflow uses separate `_clean` tables in MySQL so that raw source tables can be retained. `Data/Cleaned/` does not need to contain exported copies of those tables unless exports are deliberately added.

## Getting Started

1. Install MySQL 8.0 and open MySQL Workbench.
2. Obtain the Olist dataset from its original source and place the CSV files in `Data/Raw/`.
3. Review the database setup and import requirements before loading the data. The original Phase 1 setup/import script has not yet been fully recovered, so a clean-room import should not be assumed to be turnkey.
4. Open the relevant phase scripts in `SQL/` and run them in sequence against the `olist_ecommerce` schema, checking each phase report in `Reports/`.
5. Review `Reports/09_Business_Insights_Report.md` for the detailed business conclusions.


## Scope and Limitations

This project focuses on SQL-based data engineering and analytics. Machine learning, predictive modelling, real-time pipelines, and cloud deployment are outside its scope.

The findings describe patterns in the available dataset. Observed relationships—such as the relationship between delivery delays and review scores—should not be interpreted as causal effects without further analysis.

## Project Status

Phases 1–9 have been completed as analytical work. Final documentation and portfolio preparation are in progress. Recovery of the original Phase 1 setup/import script remains on hold and is documented as a reproducibility limitation.
