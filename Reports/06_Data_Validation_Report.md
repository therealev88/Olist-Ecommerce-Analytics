# Phase 6 – Data Validation Report

## 1. Objective

Validate the cleaned tables created during Phase 5 before beginning exploratory data analysis.

Validation focused on identifiers, required fields, domain rules, timestamp chronology, referential integrity, and preservation of expected records.

---

## 2. Validation Approach

- Validate each cleaned table independently.
- Confirm primary identifiers remain unique.
- Check required fields for NULL or invalid values.
- Recheck known data-quality issues after cleaning.
- Validate logical relationships between related tables.
- Confirm no records were unintentionally removed.
- Preserve unresolved source-data anomalies rather than introducing unsupported corrections.

---

## 3. Validation Results

### 3.1 Customers

Customer identifiers and required geographic fields passed validation.

Results:
- Total customers: 99,441
- Unique customer IDs: 99,441
- Invalid customer IDs: 0
- Invalid customer unique IDs: 0
- NULL ZIP prefixes: 0
- Invalid states: 0

Status: Passed.

### 3.2 Orders

Order timestamps were validated after the Phase 5 zero-date conversion.

Results:
- Total orders: 99,441
- NULL purchase timestamps: 0
- Approval-before-purchase violations: 0
- NULL approval timestamps: 160
- NULL carrier timestamps: 1,783
- NULL customer-delivery timestamps: 2,965

The known chronology anomalies remain:
- Carrier before approval: 1,359
- Customer delivery before carrier delivery: 23

These were retained because the source data does not establish which timestamps are incorrect.

Status: Passed with documented source-data anomalies.

### 3.3 Order Items

Order-item identifiers and relationships were validated.

Results:
- Total order items: 112,650
- Unique `(order_id, order_item_id)` keys: 112,650
- Orphaned orders: 0
- Orphaned products: 0
- Orphaned sellers: 0

Status: Passed.

### 3.4 Products

Product identifiers and cleaned attributes passed validation.

Results:
- Total products: 32,951
- Unique product IDs: 32,951
- Invalid product IDs: 0
- Remaining zero values in cleaned attributes: 0
- Negative physical dimensions: 0

Status: Passed.

### 3.5 Sellers

Seller identifiers and order-item relationships passed validation.

Results:
- Total sellers: 3,095
- Unique seller IDs: 3,095
- Invalid seller IDs: 0
- Sellers without associated order items: 0

The geographic inconsistencies identified during Phase 4 remain unchanged and documented.

Status: Passed with documented source-data anomalies.

### 3.6 Order Payments

Payment values and installment values were validated.

Results:
- Total payments: 103,886
- Negative payment values: 0
- Negative installments: 0
- Invalid payment types: 0
- `not_defined` payment records: 3
- Zero-installment credit-card records: 2

The three undefined payment types and two zero-installment credit-card records remain unresolved because their intended source values cannot be established.

Status: Passed with documented source-data anomalies.

### 3.7 Order Reviews

Review identifiers, scores, timestamps, and comments were validated.

Results:
- Total reviews: 99,223
- Unique review IDs: 98,409
- Invalid review scores: 0
- NULL review creation dates: 0
- NULL review answer timestamps: 0
- NULL review comments: 58,256
- Remaining blank comments: 0

Repeated review IDs remain present as documented source-data characteristics.

Status: Passed with documented source-data characteristics.

### 3.8 Geolocation

Geolocation records and coordinates passed validation.

Results:
- Total records: 1,000,163
- NULL ZIP prefixes: 0
- NULL latitude values: 0
- NULL longitude values: 0
- Invalid latitude values: 0
- Invalid longitude values: 0

Status: Passed.

### 3.9 Product Category Translation

Category mappings passed validation.

Results:
- Total mappings: 71
- Unique Portuguese categories: 71
- Unique English categories: 71
- Missing Portuguese categories: 0
- Missing English categories: 0

Status: Passed.

---

## 4. Cross-Table Referential Integrity

The core relationships between cleaned tables were validated.

| Relationship | Orphan Records |
|---|---:|
| Orders → Customers | 0 |
| Order Items → Orders | 0 |
| Order Items → Products | 0 |
| Order Items → Sellers | 0 |
| Payments → Orders | 0 |
| Reviews → Orders | 0 |

All six relationships passed.

---

## 5. Known Unresolved Issues

The following source-data characteristics remain documented rather than artificially corrected:

- 1,359 carrier-before-approval timestamp sequences.
- 23 customer-before-carrier delivery sequences.
- Seller geographic inconsistencies.
- 2 credit-card records with zero installments.
- 3 `not_defined` payment types.
- Repeated review IDs.
- Multiple city names associated with some geolocation ZIP prefixes.

These do not prevent the cleaned dataset from proceeding to exploratory analysis, but they should be considered when interpreting relevant findings.

---

## 6. Conclusion

Phase 6 confirmed that the cleaned dataset is structurally and referentially sound for analytical use.

Identifiers remain valid and unique where expected, cleaned values satisfy the defined validation rules, and all tested core relationships contain zero orphan records.

Known source-data anomalies have been preserved and documented rather than altered without sufficient evidence.

The cleaned dataset is ready for Phase 7 – Exploratory Data Analysis.