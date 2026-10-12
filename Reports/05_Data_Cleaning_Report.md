# Phase 5 – Data Cleaning Report

## 1. Objective

Create cleaned copies of the project tables while preserving the original imported data.

Cleaning was limited to issues that could be addressed with reasonable confidence. Where the source data did not provide enough evidence for a correction, the original value was retained and the issue documented.

---

## 2. Cleaning Approach

- Original source tables were not modified.
- Cleaned copies were created using the `_clean` suffix.
- Confirmed import artifacts and missing-value representations were standardized.
- Ambiguous source-data inconsistencies were not overwritten.
- Each transformation was validated after execution.
- Final row counts were checked across all cleaned tables.

---

## 3. Cleaning Performed

### 3.1 Customers

Six customer records used `embu` instead of `embu das artes`.

The affected records matched the identified ZIP prefixes and `SP` state associated with `embu das artes`. These six records were standardized to `embu das artes`.

Validation:
- Remaining `embu` records: 0
- `embu das artes` records after cleaning: 66
- Total customers: 99,441

### 3.2 Orders

Imported zero dates were converted to `NULL` in:

- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`

A total of 2,980 values were changed.

Validation confirmed:
- Zero approval dates: 0
- Zero carrier dates: 0
- Zero customer delivery dates: 0
- NULL approval dates: 160
- NULL carrier dates: 1,783
- NULL customer delivery dates: 2,965

The 23 orders with contradictory delivery chronology were not altered because the available data did not establish which timestamp was incorrect.

### 3.3 Order Items

No confirmed data-quality issue required transformation.

A cleaned copy was created and validated.

Validation:
- Total records: 112,650
- Unique `(order_id, order_item_id)` keys: 112,650

### 3.4 Products

The 610 products affected by the import-related zero values were cleaned.

The following zero values were converted to `NULL`:

- `product_name_lenght`
- `product_description_lenght`
- `product_photos_qty`

Validation confirmed:
- Remaining zero values in all three fields: 0
- NULL values in all three fields: 610

### 3.5 Sellers

A cleaned copy was created, but the geographic inconsistencies identified during the quality assessment were not overwritten.

The conflicting ZIP/state combinations did not provide sufficient evidence to determine the correct value for the affected sellers.

Validation:
- Total sellers: 3,095
- Unique seller IDs: 3,095

### 3.6 Order Payments

A cleaned copy was created.

Two credit-card records contain positive payment values with zero installments. The intended installment values could not be determined from the available data, and the column does not allow `NULL`, so the original values were retained.

Three records have `payment_type = 'not_defined'` with zero payment values. Their intended payment types could not be established, so they were also retained.

Validation:
- Total payments: 103,886
- `not_defined` payments: 3
- Zero-installment credit-card records: 2

No unsupported payment values were introduced.

### 3.7 Order Reviews

Blank review comments were converted to `NULL`.

A total of 58,256 blank comments were standardized.

Validation:
- Total reviews: 99,223
- NULL comments: 58,256
- Remaining blank comments: 0

Repeated `review_id` values were not deduplicated because the records could not be established as duplicate reviews based on the available data.

### 3.8 Geolocation

No transformation was required.

A cleaned copy was created and validated.

Validation:
- Total records: 1,000,163
- Invalid latitude values: 0
- Invalid longitude values: 0

The multiple-city-per-ZIP observations identified during quality assessment were retained as source-data characteristics.

### 3.9 Product Category Translation

No transformation was required.

Validation:
- Total mappings: 71
- Unique Portuguese categories: 71
- Unique English categories: 71
- Missing Portuguese categories: 0
- Missing English categories: 0

---

## 4. Final Validation

All cleaned tables preserved their expected row counts.

| Clean Table | Rows |
|---|---:|
| customers_clean | 99,441 |
| orders_clean | 99,441 |
| order_items_clean | 112,650 |
| products_clean | 32,951 |
| sellers_clean | 3,095 |
| order_payments_clean | 103,886 |
| order_reviews_clean | 99,223 |
| geolocation_clean | 1,000,163 |
| product_category_name_translation_clean | 71 |

No records were deleted during the cleaning phase.

---

## 5. Issues Deliberately Left Unchanged

The following issues were retained because a defensible correction could not be established from the dataset:

- 23 orders with contradictory delivery timestamp chronology.
- Seller geographic inconsistencies across ZIP/state combinations.
- Two credit-card records with zero installments.
- Three `not_defined` payment types.
- Repeated review IDs across multiple orders.
- Multiple city names associated with some geolocation ZIP prefixes.

These issues will be considered during Phase 6 – Data Validation where relevant.

---

## 6. Conclusion

Phase 5 produced cleaned copies of all nine project tables while preserving the original imported data.

Confirmed missing-value and import-related issues were standardized, while ambiguous source-data anomalies were preserved rather than corrected through unsupported assumptions.

The cleaned tables are ready for Phase 6 – Data Validation.