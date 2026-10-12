# Olist E-commerce Analytics Project Blueprint

## Project Overview

This project builds and analyzes a relational database from the Olist Brazilian E-commerce dataset using MySQL 8.0. Its purpose is to develop SQL mastery through a reproducible, end-to-end workflow that moves from raw data ingestion to validated analysis and business insights.

The project demonstrates practical database engineering, data quality assessment, analytical SQL, and evidence-based business interpretation.

---

## Objectives

### Primary Objective

Develop strong SQL skills by building, validating, and analyzing a relational database using real-world e-commerce data.

### Secondary Objectives

- Build a reproducible database ingestion workflow.
- Verify database structure and relationships.
- Profile the data and assess its quality.
- Create cleaned tables while preserving the original imported tables.
- Validate cleaned data and cross-table relationships.
- Perform exploratory analysis and advanced SQL analysis.
- Translate analytical findings into clearly qualified business insights.
- Deliver a professional, reproducible GitHub portfolio project.

---

## Project Scope

### Included

- Database engineering and CSV ingestion
- Database verification
- Data profiling
- Data quality assessment
- Data cleaning
- Data validation
- Exploratory Data Analysis (EDA)
- Advanced SQL techniques
- Business insight generation
- Phase-specific reports and comprehensive documentation
- Selected data-driven charts for communicating findings

### Excluded

- Machine learning
- Predictive modelling
- Real-time data pipelines
- Cloud deployment

---

## Project Phases

| Phase | Name | Deliverables | Status |
|---|---|---|---|
| 1 | Database Engineering | Database setup and ingestion scripts/artifacts | Completed; exact SQL script availability to be verified |
| 2 | Database Verification | `02_Database_Inventory.sql` and `02_Database_Inventory_Report.md` | Completed |
| 3 | Data Profiling | `03_Data_Profiling.sql` and `03_Data_Profiling_Report.md` | Completed |
| 4 | Data Quality Assessment | `04_Data_Quality_Assessment.sql` and `04_Data_Quality_Assessment_Report.md` | Completed |
| 5 | Data Cleaning | `05_Data_Cleaning.sql` and `05_Data_Cleaning_Report.md` | Completed |
| 6 | Data Validation | `06_Data_Validation.sql` and `06_Data_Validation_Report.md` | Completed |
| 7 | Exploratory Data Analysis | `07_Exploratory_Data_Analysis.sql` and `07_Exploratory_Data_Analysis_Report.md` | Completed |
| 8 | Advanced SQL | `08_Advanced_SQL.sql` and `08_Advanced_SQL_Report.md` | Completed |
| 9 | Business Insights | `09_Business_Insights.sql` and `09_Business_Insights_Report.md` | Completed |
| 10 | Final Comprehensive Documentation | Comprehensive project documentation and repository alignment | In progress |

Phase-specific SQL files and reports are maintained separately. Phase 1's exact script filename and availability will be confirmed during the repository finalization process.

---

## Data and Database Approach

The project uses nine Olist source tables:

- `customers`
- `orders`
- `order_items`
- `products`
- `sellers`
- `order_payments`
- `order_reviews`
- `geolocation`
- `product_category_name_translation`

The original imported tables are preserved. Cleaning transformations are applied to separate `_clean` tables so that source data remains available for comparison and reproducibility.

The workflow follows this sequence:

**Raw data → Database engineering → Verification → Profiling → Quality assessment → Cleaning → Validation → EDA → Advanced SQL → Business insights → Final documentation**

---

## Success Criteria

- A relational MySQL database built from the source CSVs.
- Database structure, keys, and relationships inspected.
- Data profiling and quality findings documented.
- Cleaning transformations applied reproducibly to separate clean tables.
- Cleaned tables validated, including cross-table referential integrity.
- Exploratory analysis completed and findings documented.
- Advanced SQL techniques demonstrated through defined analytical problems.
- Business insights supported by query results and appropriately qualified.
- A clear, consistent GitHub repository with phase-specific SQL and reports.
- Final comprehensive documentation and selected analytical visualizations completed.

---

## Deliverables

- MySQL database and database-engineering artifacts
- Phase 2–9 SQL scripts
- Phase 2–9 Markdown reports
- Project Blueprint
- Final comprehensive documentation
- Selected analytical charts in `Images/`
- GitHub `README.md`

The project does not maintain a separate Master Project Log. Important decisions and results are recorded in the report for the relevant phase.

---

## Working Principles

1. Import raw data before cleaning.
2. Never modify the original source CSV files.
3. Keep transformations reproducible.
4. Profile data before cleaning.
5. Validate after major transformations.
6. Document important decisions and findings, not every action.
7. Preserve ambiguous records when there is insufficient evidence to correct them safely.
8. Distinguish measured results from interpretation; do not present association as causation.
9. Keep SQL comments and phase reports concise and focused.
10. Keep the repository structure consistent with the established project layout.

---

## Milestones

- [x] Database construction and source-data ingestion
- [x] Database verification
- [x] Data profiling
- [x] Data quality assessment
- [x] Data cleaning
- [x] Data validation
- [x] Exploratory Data Analysis
- [x] Advanced SQL
- [x] Business insights
- [ ] Repository alignment and artifact verification
- [ ] Curate and add selected analytical charts
- [ ] Complete comprehensive documentation
- [ ] Finalize README and perform final repository review

---

## Current Status

**Current Phase:** Phase 10 — Final Comprehensive Documentation

Phases 1–9 have been completed in the project workflow. During finalization, the repository will be checked against the established structure. The availability of the Phase 1 engineering SQL script will be verified rather than assumed. The final documentation, selected charts, and README will be aligned with the actual project artifacts.

---

## Repository Structure

The project uses the repository hierarchy established at the outset:

- `Data/Raw/` — original source CSV files
- `Data/Cleaned/` — location for cleaned data exports, if retained as repository artifacts
- `Database/` — database-related artifacts, to be confirmed during repository audit
- `Documentation/` — Blueprint and final comprehensive documentation
- `Images/` — selected analytical visualizations
- `Reports/` — phase-specific Markdown reports
- `SQL/` — phase-specific SQL scripts
- `README.md` — concise entry point for the GitHub project

The final documentation will describe actual contents and will not assume that an empty folder contains artifacts.

---

## Analytical and Data Limitations

- The dataset represents a historical observation period, not current marketplace activity.
- Recorded payment value is an analytical measure and should not automatically be described as recognized revenue.
- Relationships between delivery, order value, category, and review scores are observational; association does not establish causation.
- Repeat-customer analysis is limited to the dataset's observation window and is not a complete lifetime-retention measure.
- Some source-data inconsistencies and ambiguous payment records were preserved where a defensible correction could not be established.
- Very small groups may produce unstable averages or percentages.
- Dataset boundary periods, especially the final months, require caution when interpreting trends.

---

## Finalization Checklist

- [ ] Confirm the Phase 1 engineering script's filename and availability.
- [ ] Verify the contents of the `Database/` folder and decide which artifacts belong there.
- [ ] Decide whether cleaned data exports belong in `Data/Cleaned/`.
- [ ] Create selected analytical charts from verified results.
- [ ] Complete the comprehensive documentation in `Documentation/`.
- [ ] Replace the empty `README.md.txt` with a populated `README.md`.
- [ ] Verify filenames, links, report coverage, and repository consistency.
