# Olist E-commerce Analytics Project
## Comprehensive Project Report

**Project type:** SQL data engineering and analytics portfolio project  
**Database:** MySQL 8.0  
**Working environment:** MySQL Workbench  
**Dataset:** Olist Brazilian e-commerce marketplace dataset  
**Documentation status:** Phase 10 — comprehensive documentation in progress

---

## 10.1 Project Overview and Objectives

This project uses SQL to inspect, verify, profile, assess, clean, validate, and analyze a multi-table e-commerce dataset. The aim is to demonstrate a complete analytical workflow, from relational database inspection through data-quality treatment and business-focused analysis.

The work is organized into ten phases:

1. Database Engineering
2. Database Verification
3. Data Profiling
4. Data Quality Assessment
5. Data Cleaning
6. Data Validation
7. Exploratory Data Analysis (EDA)
8. Advanced SQL
9. Business Insights
10. Final Documentation

The emphasis is on learning and applying SQL to a real relational dataset. The project uses MySQL queries for structural checks, profiling, transformations, validation, aggregation, customer sequencing, ranking, segmentation, and business analysis.

The concise repository `README.md` serves as the portfolio entry point. This report is the fuller technical case study and consolidates the phase reports without replacing them.

### Objectives

- Verify the database structure and imported record counts.
- Understand the shape, completeness, uniqueness, and distributions of the source data.
- Distinguish confirmed data-quality issues from legitimate or ambiguous source-data characteristics.
- Preserve source tables while applying defensible transformations to cleaned copies.
- Validate identifiers, values, timestamps, and core table relationships.
- Use descriptive and advanced SQL to answer commercial and operational questions.
- State limitations clearly and avoid interpreting associations as proof of causation.

---

## 10.2 Dataset Overview

The project database contains nine core tables:

| Table | Rows |
|---|---:|
| `customers` | 99,441 |
| `orders` | 99,441 |
| `order_items` | 112,650 |
| `products` | 32,951 |
| `sellers` | 3,095 |
| `order_payments` | 103,886 |
| `order_reviews` | 99,223 |
| `geolocation` | 1,000,163 |
| `product_category_name_translation` | 71 |

These counts were documented during database inventory and subsequent cleaning/validation. Corresponding `_clean` tables were reported with the same row counts.

The tables cover customer and seller locations, order lifecycle events, line items, products and categories, payment components, reviews, and ZIP-prefix geolocation. The data supports analysis of marketplace growth, category concentration, repeat purchasing, delivery performance, seller value, and interstate trade.

The row counts are useful context, but they do not by themselves prove that every field was imported without issue. The profiling and quality-assessment phases identified several import artifacts and source-data anomalies that were carried forward into cleaning and validation.

---

## 10.3 Database Architecture and Schema

The database is named `olist_ecommerce`. The project maintains two layers:

- **Raw tables:** imported source data retained as the reference layer.
- **Cleaned tables:** copies named with the `_clean` suffix, used for defensible standardization and subsequent analysis.

The cleaned tables were created from the raw tables; the cleaning report states that original source tables were not modified. This separation makes it possible to compare transformations with the imported values and retain unresolved anomalies transparently.

The structure export inspected during the project contains definitions for all nine raw tables and nine corresponding cleaned tables. The raw schema includes primary keys where applicable and four foreign-key constraints were recorded in the inventory report. The geolocation table does not have a primary key in the inspected schema. Cleaned tables created with `CREATE TABLE ... AS SELECT` do not automatically reproduce all source-table constraints; therefore, the existence of matching columns and row counts should not be confused with identical constraint definitions.

### Core relationships checked

- Orders → Customers
- Order Items → Orders
- Order Items → Products
- Order Items → Sellers
- Payments → Orders
- Reviews → Orders

Phase 6 reported zero orphan records for all six relationships in the cleaned data.

**Reproducibility caution:** The structure dump includes `DROP TABLE IF EXISTS` statements. It should not be executed blindly against an active database because it can delete existing tables. Review the script and target schema before running any destructive statements.

---

## 10.4 Data Ingestion and Engineering

The original CSV datasets were imported into MySQL using `LOAD DATA LOCAL INFILE` rather than relying exclusively on the Workbench import wizard. The project history records checking the `local_infile` setting and enabling it for the import workflow. The setting was also configured in the MySQL server options.

The available Workbench history confirms that the database schema was created and that the `customers` table was defined early in the process. It also contains an import attempt with a questionable file name and column mapping. That historical statement is retained as evidence of an attempted operation, **not** as a recommended or verified import script.

### Import issues recorded during the work

- **Orders:** blank lifecycle timestamps were imported as `0000-00-00 00:00:00`; the Phase 4 report records an initial warning count of 1,024.
- **Products:** empty numeric fields became zero in `product_name_lenght`, `product_description_lenght`, and `product_photos_qty`; 610 affected records were identified.
- **Order reviews:** UTF-8/emoji handling and line-ending issues caused import warnings or errors. The inspected schema uses `utf8mb3`, which cannot represent all four-byte Unicode characters.
- **Geolocation:** an initial import attempt returned zero rows; the line-ending handling was subsequently addressed. The final table contained 1,000,163 records.
- **Other tables:** the project reports that most other imports completed without major issues.

These issues illustrate why successful table creation and nonzero row counts are not sufficient import checks. Data types, empty values, character sets, line endings, warning counts, and row counts also need inspection.

### Phase 1 recovery status

A complete original Phase 1 setup/import script was not recovered from the available project history. The structure export establishes the resulting table definitions, but it does not prove the exact original SQL statements used to create every table or load every file. This report therefore documents the known workflow and known limitations without presenting reconstructed commands as original evidence.

---

## 10.5 Database Verification and Profiling

### Database verification

Phase 2 checked that the expected tables existed, compared imported row counts, reviewed column definitions and data types, and inspected primary keys, foreign keys, and indexes. The phase report states that all expected tables were present and imported row counts matched the source datasets.

### Profiling approach

Phase 3 examined the nine tables for record counts, identifier uniqueness, NULL and blank values, value ranges, distributions, relationships, and notable anomalies. The work also checked order lifecycle timestamp consistency, payment patterns, review completeness, coordinate validity, and category mapping uniqueness.

Key observations included:

- `customer_unique_id` is not one-to-one with `customer_id`; multiple customer records can represent the same customer.
- Zero-date values existed in order lifecycle timestamp fields.
- Product numeric fields contained import-generated zeros.
- Some customer city names appeared inconsistent for the same ZIP prefixes.
- Seller ZIP/state combinations showed geographic inconsistencies that could not all be resolved from the dataset.
- Multiple orders could be associated with the same `review_id`; the records were not automatically treated as duplicates.
- Geolocation ZIP prefixes could map to multiple city names. This was retained as a source-data characteristic because the evidence did not establish which values, if any, were wrong.
- The category translation table had 71 mappings and no significant completeness or uniqueness issues.

Profiling did not automatically equate repeated values or unusual distributions with errors. Findings were carried into Phase 4 for classification.

---

## 10.6 Data-Quality Assessment

Phase 4 separated confirmed issues from anomalies that required investigation or were better treated as source-data characteristics.

### Main findings

**Orders**
- Zero-date values were found in `order_approved_at` (160), `order_delivered_carrier_date` (1,783), and `order_delivered_customer_date` (2,965).
- Twenty-four delivered orders had at least one zero-date timestamp and required special attention.
- Twenty-three orders had customer-delivery timestamps earlier than carrier-delivery timestamps.
- An initial check identified 1,359 carrier-before-approval sequences. Sample inspection did not establish that these were necessarily invalid, so they were not classified as confirmed errors.

**Products**
- Six hundred and ten product records contained zero values in the three affected numeric attributes, corresponding to empty values observed during import.

**Customers and sellers**
- Six customer records across five ZIP prefixes used `embu` where `embu das artes` was the supported standardized city value.
- Seventeen seller ZIP prefixes, affecting 45 seller records, had geographic inconsistencies. These were not corrected without sufficient evidence.

**Payments**
- Nine payment records had zero payment value; these were not all classified as invalid because zero-value voucher or `not_defined` components can occur.
- Two credit-card records had positive payment values but zero installments.
- Three records used `payment_type = 'not_defined'`.

**Reviews**
- 58,256 review-comment fields were blank strings.
- 789 `review_id` values were associated with multiple orders, with a maximum of three orders per review ID. Sample inspection found matching scores and timestamps, so they were not automatically deduplicated.
- The import's character-set limitation was documented.

**Geolocation and category translation**
- Latitude and longitude values were within valid global ranges.
- The 71 category translation mappings had unique Portuguese and English category names and no missing mapping values.
- Multiple city names per ZIP prefix were not assumed to be errors without external or source-supported evidence.

The core principle was conservative treatment: transform what can be justified, and document what cannot.

---

## 10.7 Data-Cleaning Methodology

Phase 5 created cleaned copies of all nine tables. No records were deleted, and the original imported tables were preserved.

| Cleaned table | Treatment |
|---|---|
| `customers_clean` | Standardized six confirmed `embu` city values to `embu das artes` for the specified ZIP prefixes and state |
| `orders_clean` | Converted imported zero-date values to `NULL` in three lifecycle timestamp fields |
| `order_items_clean` | Created a copy; no confirmed transformation was required |
| `products_clean` | Converted the import-generated zero values in three affected numeric attributes to `NULL` |
| `sellers_clean` | Created a copy; unresolved geographic inconsistencies were preserved |
| `order_payments_clean` | Created a copy; unresolved installment and payment-type anomalies were preserved |
| `order_reviews_clean` | Converted blank review comments to `NULL` |
| `geolocation_clean` | Created a copy without changing source values |
| `product_category_name_translation_clean` | Created a copy; validated mappings were preserved |

### Results recorded after cleaning

- **Orders:** zero-date values remaining in the three treated columns: 0. The resulting NULL counts were 160 approval timestamps, 1,783 carrier timestamps, and 2,965 customer-delivery timestamps. The report records 2,980 zero-date values changed in total.
- **Products:** the three affected attributes had no remaining zeros; 610 NULL values were recorded in each.
- **Customers:** no remaining `embu` values in the targeted records; 66 `embu das artes` records after standardization; 99,441 total customers.
- **Reviews:** 58,256 comment fields were standardized to NULL, with no remaining blank comment strings; 99,223 reviews retained.
- **Order items:** 112,650 rows and 112,650 unique `(order_id, order_item_id)` keys.
- **Sellers:** 3,095 rows and 3,095 unique seller IDs.
- **Geolocation:** 1,000,163 rows and zero invalid latitude or longitude values.
- **Category translations:** 71 mappings, with 71 unique values in each language column and no missing mapping names.

The two zero-installment credit-card records, three `not_defined` payment types, 23 contradictory delivery sequences, seller geographic inconsistencies, repeated review IDs, and geolocation naming variation were deliberately retained because a defensible correction could not be inferred from the available data.

---

## 10.8 Data-Validation Results

Phase 6 validated cleaned-table identifiers, required fields, value domains, timestamp logic, and cross-table relationships. The report records the following outcomes:

| Validation area | Recorded result |
|---|---|
| Customers | 99,441 rows; 99,441 unique customer IDs; no invalid IDs, NULL ZIP prefixes, or invalid states |
| Orders | 99,441 rows; no NULL purchase timestamps; zero-date conversion confirmed |
| Order items | 112,650 rows; 112,650 unique composite keys; zero orphaned orders, products, or sellers |
| Products | 32,951 rows; unique product IDs; no remaining zeros in the treated fields; no negative physical dimensions |
| Sellers | 3,095 rows; 3,095 unique seller IDs; no sellers without associated order items |
| Payments | 103,886 rows; no negative payment values or installments; three `not_defined` records and two zero-installment credit-card records remain |
| Reviews | 99,223 rows; 98,409 unique review IDs; no invalid review scores; 58,256 NULL comments and no remaining blank comments |
| Geolocation | 1,000,163 rows; no NULL ZIP/coordinate fields and no invalid coordinate values |
| Category translations | 71 mappings; unique Portuguese and English names; no missing names |

The six tested relationships—orders to customers, order items to orders/products/sellers, payments to orders, and reviews to orders—each had zero orphan records.

The validation phase passed the defined structural and relationship checks while documenting unresolved source-data anomalies. “Passed” does not mean that every source value is known to be correct; it means the stated checks were satisfied and remaining exceptions were recorded.

---

## 10.9 Exploratory Data Analysis

Phase 7 used SQL aggregations and grouped comparisons to explore marketplace activity across time, customers, products and categories, sellers, payments, reviews, delivery, and geography. The phase report records monthly order and payment trends, delivery performance, customer behavior, product/category contribution, seller activity, payment methods, review patterns, and geographic distribution.

The time-series analysis showed strong growth in recorded marketplace activity between early 2017 and early 2018. Later business analysis quantified this change and distinguished growth in order volume from average order value.

EDA also established analytical baselines for the advanced SQL and business-insight phases. These analyses describe the recorded dataset; payment value is not automatically equivalent to accounting revenue, profit, or seller payout.

The original Phase 7 report and SQL file should be consulted for the detailed query sequence and table-level results. This consolidated report retains the main supported conclusions rather than reproducing every EDA query.

---

## 10.10 Advanced SQL Techniques

Phase 8 extended the work from descriptive aggregation to multi-step analytical SQL. The techniques documented in the phase report include:

- Common table expressions (CTEs) to organize multi-stage query logic.
- Window functions for ranking and cumulative contribution.
- `ROW_NUMBER()` to sequence a customer's orders chronologically.
- `LAG()` to retrieve the previous order and calculate intervals between purchases.
- `RANK()` for seller ranking within state.
- `NTILE(5)` to divide customers or sellers into relative groups.
- RFM-style customer segmentation using recency, frequency, and monetary value.
- Category concentration analysis using percentage-of-total and cumulative-share calculations.
- A multi-stage seller performance query combining order count, item count, item value, average item value, state ranking, quintiles, and segmentation.

### Selected documented results

**Repeat-purchase intervals**

| Interval | Repeat purchases | Repeat customers | Share |
|---|---:|---:|---:|
| 0–30 days | 1,713 | 1,595 | 51.21% |
| 31–90 days | 616 | 591 | 18.42% |
| 91–180 days | 476 | 465 | 14.23% |
| 181+ days | 540 | 535 | 16.14% |

These figures describe observed repeat-purchase intervals. They are not a formal retention rate because customers who never returned are not represented in the interval distribution.

**Category contribution:** the top 5 categories account for 39.16% of item value, and the top 10 account for 62.32% cumulatively. These two thresholds are used consistently in the business narrative.

**Seller performance:** the capstone seller query returned 3,095 rows, matching the cleaned seller count.

The phase focused on choosing techniques to solve meaningful analytical problems, not adding advanced syntax without a purpose.

---

## 10.11 Business Insights and Recommendations

Phase 9 translated the SQL analysis into eight business questions. The numerical results below are those recorded in the Phase 9 report.

### 1. Marketplace growth was primarily volume-driven

Comparing early 2017 with early 2018:

| Metric | Early 2017 average per month | Early 2018 average per month | Change |
|---|---:|---:|---:|
| Orders | 1,754 | 7,069.33 | +303.0% |
| Recorded payment value | R$293,419.88 | R$1,089,039.88 | +271.3% |
| Average order value | R$168.28 | R$153.91 | −8.5% |

**Interpretation:** Order volume and recorded payment value grew substantially while average order value declined. The reported pattern is therefore more consistent with volume-led growth than increasing basket size.

### 2. Commercial value is concentrated among leading categories

The Phase 9 report recorded the following concentration findings:

- **Top 5 categories:** R$6,204,400.28, representing **39.16%** of item value.
- **Top 10 categories:** **62.32%** of item value cumulatively.

**Recommendation:** Monitor category concentration and avoid interpreting catalogue breadth as evidence that value is evenly distributed.

### 3. The observed customer base is dominated by one-time customers

| Customer group | Customers | Customer share | Orders | Order share | Recorded payment value | Value share |
|---|---:|---:|---:|---:|---:|---:|
| One-time | 93,098 | 96.88% | 93,098 | 93.62% | R$15.06M | 94.10% |
| Repeat | 2,997 | 3.12% | 6,342 | 6.38% | R$944K | 5.90% |

**Interpretation:** The recorded customer population is dominated by one-time purchasers. This does not, by itself, prove poor retention: customers may not have had enough time to make another purchase within the dataset's observation window.

**Recommendation:** If this were a business analysis, cohort-based repeat-purchase tracking over a defined observation period would be a useful next step.

### 4. Repeat customers have higher average recorded value

| Customer group | Customers | Average orders per customer | Average customer value |
|---|---:|---:|---:|
| One-time | 93,098 | 1.00 | R$161.82 |
| Repeat | 2,997 | 2.12 | R$314.99 |

The report calculates repeat-customer average value as approximately 94.7% higher than one-time customer value.

**Recommendation:** Repeat purchasing is a plausible area for further investigation, but the descriptive difference does not establish that any particular retention initiative would cause higher value.

### 5. Late delivery is strongly associated with lower review scores

| Delivery status | Reviewed orders | Average review score | Negative reviews |
|---|---:|---:|---:|
| On time | 88,652 | 4.29 | 9.23% |
| Late | 7,700 | 2.57 | 54.03% |

The Phase 9 report records a 1.72-point lower average review score for late deliveries and a negative-review rate nearly six times that of on-time deliveries.

**Interpretation:** Delivery performance and customer satisfaction are strongly associated in the analyzed records. This is observational analysis and does not prove that lateness alone caused the difference.

**Recommendation:** Delivery reliability is a reasonable operational priority for further investigation, including potential category and seller-level differences.

### 6. Office furniture is a notable combined delivery and satisfaction concern

Among categories with at least 500 reviews, the Phase 9 report identifies office furniture as having a 3.52 average review score and a 9.00% late-delivery rate across 1,246 reviews. Other categories with weaker satisfaction and elevated late rates included bed_bath_table, furniture_decor, telephony, baby, health_beauty, and auto.

Electronics was an important counterexample: it had a reported late rate of 9.81% but an average review score of 4.07.

**Interpretation:** Delivery rates do not fully explain category-level satisfaction. Further analysis should consider product expectations, product quality, seller mix, and other possible factors before assigning a cause.

### 7. Seller value is distributed across a broad base, with a strong scale/value association

| Seller group | Item value | Share |
|---|---:|---:|
| Top 10 sellers | R$2.03M | 12.80% |
| Sellers 11–50 | R$3.08M | 19.44% |
| Sellers 51–100 | R$1.92M | 12.13% |
| Remaining sellers | R$8.81M | 55.63% |

The top 100 sellers generated 44.37% of item value. The report also records average seller value of R$384.31 in Q1 versus R$19,575.76 in Q5.

**Interpretation:** Value is not limited to the top 10 sellers, and higher seller-volume groups are associated with higher commercial value. This does not prove that volume alone causes higher value.

### 8. Interstate transactions account for most recorded activity and value

| Trade type | Orders | Order share | Item value | Value share | Average order value |
|---|---:|---:|---:|---:|---:|
| In-state | 35,600 | 35.89% | R$4.80M | 30.28% | R$134.76 |
| Interstate | 63,583 | 64.11% | R$11.05M | 69.72% | R$173.72 |

The Phase 9 report calculates interstate average order value as approximately 28.9% higher than in-state average order value.

**Interpretation:** Interstate transactions represent the majority of orders and a disproportionately high share of recorded item value.

### Business-insight summary

The Phase 9 analysis supports the following overall conclusions:

1. Marketplace growth was primarily volume-driven.
2. Item value is concentrated among leading product categories.
3. The observed customer base is predominantly one-time purchasers.
4. Repeat customers have higher average recorded customer value.
5. Late delivery is strongly associated with lower customer satisfaction.
6. Office furniture is a notable category for further delivery and satisfaction investigation.
7. Seller value is distributed across many sellers, while scale is associated with higher value.
8. Interstate commerce is disproportionately valuable in the analyzed records.

These are descriptive findings based on the dataset and project queries, not causal estimates or audited financial results.

---

## 10.12 Limitations and Lessons Learned

### Limitations

- **Incomplete Phase 1 script recovery:** The exact original setup and import script is not fully available. The resulting schema and later workflow are documented, but a fully reproducible clean-room import sequence remains outstanding.
- **Import artifacts:** Zero dates, empty numeric values converted to zero, and review-text encoding issues affected the original import. Cleaning addressed supported cases, but encoding damage already introduced during import may not be fully recoverable from the imported table alone.
- **Unresolved source anomalies:** Timestamp chronology conflicts, seller geography inconsistencies, two zero-installment credit-card records, three `not_defined` payment types, repeated review IDs, and multiple city names per ZIP prefix remain documented rather than guessed at.
- **Observational analysis:** Associations between delivery, reviews, customer value, and seller scale do not prove causation.
- **Customer observation window:** A customer classified as one-time in this dataset may purchase again outside the available period.
- **Measure definitions:** Recorded payment value and item value are not automatically equivalent to accounting revenue, profit, or net marketplace earnings.
- **RFM segmentation:** The Phase 8 report describes the segmentation as an analytical exercise, not a production CRM classification. The large “Potential High Value” segment demonstrates the limits of simplified relative scoring.
- **Geolocation variation:** Multiple city names per ZIP prefix were preserved because the available evidence did not establish a reliable correction.

### Lessons learned

- Row counts and successful imports are necessary checks, but not sufficient proof of data quality.
- Empty values and `NULL` values are not interchangeable with numeric zero or a zero-date placeholder.
- A cleaning step should be defensible and validated; ambiguous values should not be overwritten merely to make a dataset appear consistent.
- Raw and cleaned table separation improves traceability.
- Primary keys, foreign keys, uniqueness checks, and orphan checks provide important safeguards for analytical joins.
- Window functions and CTEs are useful when the question involves sequence, ranking, segmentation, or cumulative contribution.
- Business interpretation requires careful metric definitions and explicit caveats.
- Keeping phase-specific SQL and reports makes the work easier to audit and prevents the final report from becoming a copy of every query log.

---

## 10.13 Conclusion

The Olist E-commerce Analytics project documents a structured SQL workflow across database verification, profiling, data-quality assessment, cleaning, validation, EDA, advanced SQL, and business interpretation.

The project reports nine core tables containing 99,441 orders and customers, 112,650 order items, 32,951 products, 3,095 sellers, 103,886 payment records, 99,223 review records, 1,000,163 geolocation records, and 71 category mappings. The cleaning phase created matching `_clean` tables without deleting records, standardized supported missing-value and naming issues, and preserved unresolved anomalies. Validation reported zero orphan records across six core relationships.

The analytical phases identified volume-led marketplace growth, concentrated category value, a small but higher-value repeat-customer segment, a strong association between delivery lateness and weaker reviews, broad seller participation, and the commercial importance of interstate transactions.

The project also demonstrates an important discipline: data-quality work is not simply about making values look uniform. It requires separating confirmed import artifacts from uncertain source-data behavior, validating each transformation, and communicating what the available evidence can and cannot establish.

Before treating the portfolio as fully finalized, the remaining tasks are to confirm the final README is in the repository root, review the report against the final SQL files, decide whether selected charts add value, and keep Phase 1 script recovery explicitly marked as outstanding unless the original commands are found.

---

## Source documents

This report consolidates the project's existing phase reports and SQL scripts:

- `SQL/02_Database_Inventory.sql` and `Reports/02_Database_Inventory_Report.md`
- `SQL/03_Data_Profiling.sql` and `Reports/03_Data_Profiling_Report.md`
- `SQL/04_Data_Quality_Assessment.sql` and `Reports/04_Data_Quality_Assessment_Report.md`
- `SQL/05_Data_Cleaning.sql` and `Reports/05_Data_Cleaning_Report.md`
- `SQL/06_Data_Validation.sql` and `Reports/06_Data_Validation_Report.md`
- `SQL/07_Exploratory_Data_Analysis.sql` and `Reports/07_Exploratory_Data_Analysis_Report.md`
- `SQL/08_Advanced_SQL.sql` and `Reports/08_Advanced_SQL_Report.md`
- `SQL/09_Business_Insights.sql` and `Reports/09_Business_Insights_Report.md`

The original phase reports remain the detailed evidence records for their respective phases. This comprehensive report is a synthesis and should be updated if a source query is rerun or a discrepancy is resolved.
