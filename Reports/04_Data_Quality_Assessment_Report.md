# Phase 4 — Data Quality Assessment

## Project
Olist E-commerce Analytics Project

## Objective

Assess the data quality of the Olist dataset by identifying confirmed quality issues, anomalies requiring investigation, and legitimate source-data characteristics before cleaning.

---

## 4.1 Customers

Customer identifiers were valid, with no NULL or blank customer IDs.

A geographic naming inconsistency was identified across five ZIP prefixes. The values `embu` and `embu das artes` occur under the same ZIP prefixes and state (`SP`), affecting 6 customer records. This was classified as a suspected naming inconsistency and will be addressed during cleaning.

---

## 4.2 Orders

Zero-date values were identified in three order lifecycle timestamp columns:

- `order_approved_at` — 160
- `order_delivered_carrier_date` — 1,783
- `order_delivered_customer_date` — 2,965

These zero dates generally correspond to order statuses where the relevant event had not occurred. However, 24 delivered orders contain at least one zero-date timestamp and require special handling.

A chronological inconsistency was also identified in 23 orders where the customer delivery timestamp occurs before the carrier delivery timestamp.

An initial check identified 1,359 cases where the carrier timestamp preceded the approval timestamp. Sample inspection showed that this relationship could not be reliably classified as invalid based on the available data, so it was not treated as a confirmed quality issue.

---

## 4.3 Order Items

No quality issues were identified.

- No invalid item prices
- No negative freight values
- No orphaned orders, products, or sellers
- No duplicate composite keys

The order item relationships and numeric values were consistent with the expected structure.

---

## 4.4 Products

A total of 610 product records contain zero values simultaneously in:

- `product_name_lenght`
- `product_description_lenght`
- `product_photos_qty`

These values correspond to empty numeric fields that were converted to zero during the original import. They will be converted to NULL during cleaning where appropriate.

No negative product dimensions or weights were identified.

---

## 4.5 Sellers

Seller IDs were unique across all 3,095 seller records.

Geographic inconsistencies were identified across 17 ZIP prefixes, affecting 45 seller records. Several ZIP prefixes were associated with multiple state values, including cases where otherwise consistent city/state combinations were paired with conflicting states.

These records require further investigation before any geographic correction is applied.

---

## 4.6 Order Payments

Nine payment records contain a payment value of zero. These consisted mainly of voucher and `not_defined` payment records and were not all classified as invalid because zero-value voucher records can represent payment components without an additional monetary amount.

Two credit-card records contain zero payment installments despite having positive payment values. These were classified as a confirmed quality issue.

Three records contain `payment_type = 'not_defined'`, representing an unexpected payment category requiring investigation during cleaning.

---

## 4.7 Order Reviews

No invalid review scores were identified.

A total of 789 `review_id` values are associated with multiple orders, with a maximum of three orders per review ID. Sample inspection showed identical review scores and timestamps across associated orders. These were treated as a source-data characteristic rather than automatically classified as duplicate records.

No NULL review comments were found, but 58,256 records contain blank comment strings. These represent missing written comments stored as blanks and may be standardized during cleaning.

The UTF-8 encoding limitation identified during import remains documented as a schema/data-handling issue.

---

## 4.8 Geolocation

The geolocation table contains widespread ZIP/city variation, with 550 ZIP prefixes associated with multiple city names and 547 ZIP/state combinations associated with multiple city names.

This variation was not classified as a quality error because the source data does not provide sufficient evidence to determine that these combinations are incorrect.

Latitude and longitude values were within valid global coordinate ranges, with no invalid values identified.

---

## 4.9 Product Category Translation

No quality issues were identified.

All 71 translation mappings had:

- Unique Portuguese category names
- Unique English category names
- No missing Portuguese names
- No missing English names

---

# Phase 4 Conclusion

The quality assessment identified several issues requiring treatment during the cleaning phase, particularly zero-date values, imported numeric zeros, geographic inconsistencies, invalid payment installments, undefined payment types, and blank review comments.

Other observed patterns were retained as documented source-data characteristics where the available evidence was insufficient to classify them as errors.

No source data was modified during this phase. All identified issues will be addressed or explicitly retained during Phase 5 — Data Cleaning.