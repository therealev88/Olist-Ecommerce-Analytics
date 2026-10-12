# Phase 8 — Advanced SQL Report

## 1. Objective

Phase 8 focused on applying advanced MySQL 8 SQL techniques to solve multi-step analytical problems using the cleaned Olist dataset.

The emphasis was on window functions, CTEs, ranking, sequencing, running totals, customer segmentation, and cumulative contribution analysis.

## 2. Advanced SQL Techniques Covered

- Common Table Expressions (CTEs)
- `RANK()`
- `ROW_NUMBER()`
- `LAG()`
- `NTILE()`
- `SUM() OVER()`
- Window `PARTITION BY`
- Window `ORDER BY`
- Running totals
- Percentage-of-total calculations
- Multi-stage analytical queries
- Conditional segmentation with `CASE`

## 3. 8.1 — Seller Ranking Within State

Sellers were aggregated by total item value and ranked within their respective seller states using `RANK()` and `PARTITION BY`.

The analysis demonstrated the difference between marketplace-wide ranking and ranking that restarts independently for each state. The query was extended to return the top three sellers per state.

## 4. 8.2 — Running Totals & Contribution to Total

Monthly recorded payment value was combined with cumulative payment value and each month's percentage contribution to total recorded payment value.

The analysis demonstrated how `SUM() OVER()` differs from a standard aggregate `SUM()`.

Key results:

- Total recorded payment value: approximately **R$16.01 million**.
- November 2017 was the largest individual monthly contribution at **7.46%**.
- By August 2018, cumulative recorded payment value had reached approximately **R$16.00 million**.

The measure is recorded payment value and is not classified as revenue.

## 5. 8.3 — Customer Purchase Sequence

Customer orders were sequenced chronologically using `ROW_NUMBER()`. `LAG()` was then used to identify each customer's previous purchase.

This established an order-to-order sequence within each customer's history and provided the foundation for measuring repeat-purchase intervals.

## 6. 8.4 — Repeat Customer Retention

The customer purchase sequence was extended to calculate the number of days between consecutive purchases.

| Retention interval | Repeat purchases | Repeat customers | Share |
|---|---:|---:|---:|
| 0–30 days | 1,713 | 1,595 | 51.21% |
| 31–90 days | 616 | 591 | 18.42% |
| 91–180 days | 476 | 465 | 14.23% |
| 181+ days | 540 | 535 | 16.14% |

The 0–30 day interval represented the largest share of observed repeat-purchase events.

These figures describe observed repeat-purchase intervals rather than a formal retention rate, because customers who never returned are not represented in the interval distribution.

## 7. 8.5 — Customer Segmentation

An RFM-style customer segmentation was created using recency, frequency, and monetary value. `NTILE(5)` divided customers into relative groups for each metric.

| Segment | Customers | Share | Avg Orders | Avg Value |
|---|---:|---:|---:|---:|
| High Value | 1,100 | 1.14% | 2.15 | R$380.33 |
| Potential High Value | 59,800 | 62.23% | 1.03 | R$217.80 |
| Mid Value | 34,560 | 35.96% | 1.00 | R$73.21 |
| Low Value | 635 | 0.66% | 1.00 | R$56.40 |

The large Potential High Value segment demonstrates a limitation of simplified RFM segmentation: a customer can score relatively highly on one dimension without necessarily being a frequent repeat customer.

This segmentation is an analytical exercise rather than a production CRM classification.

## 8. 8.6 — Category Contribution Analysis

Product categories were ranked by total item value and analyzed using percentage-of-total and cumulative contribution calculations.

Key cumulative contribution findings:

- Top 5 categories: **39.16%** of item value.
- Top 10 categories: **62.32%** of item value.

The analysis demonstrates how window functions evaluate concentration and cumulative contribution across ranked categories.

## 9. 8.7 — Seller Performance Analysis

A multi-stage seller performance analysis combined order count, item count, total item value, average item value, state-level ranking, value quintiles, and seller segmentation.

`RANK()` established each seller's position within their state, while `NTILE(5)` divided sellers into five relative value groups.

The final query returned **3,095 rows**, matching the number of sellers in the cleaned dataset.

This served as the capstone query for Phase 8 by combining multiple advanced SQL techniques into a single analytical pipeline.

## 10. SQL Skills Demonstrated

Phase 8 moved beyond basic aggregation and filtering into multi-step analytical SQL.

The major progression was:

**CTEs → aggregation → window functions → sequencing/ranking → segmentation → analytical interpretation**

Particular emphasis was placed on understanding:

- `RANK()` vs `ROW_NUMBER()` vs `DENSE_RANK()`
- standard aggregate functions vs window aggregates
- ranking within partitions vs ranking across the full dataset
- relative segmentation using `NTILE()`
- event sequencing using `LAG()`

## 11. Conclusion

Phase 8 demonstrated the use of advanced MySQL 8 SQL patterns to solve realistic analytical problems.

The phase successfully extended the project from descriptive EDA into more sophisticated analytical SQL while avoiding unnecessary complexity. Each advanced technique was tied to a meaningful analytical problem rather than included simply for syntax coverage.

**Phase 8 is complete.**
