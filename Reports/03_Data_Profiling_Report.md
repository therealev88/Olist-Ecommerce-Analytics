# Olist E-commerce Analytics
## Phase 3 — Data Profiling

### Objective

Profile the dataset to understand its structure, completeness,
uniqueness, distributions, and notable anomalies before
data quality assessment and cleaning.

---

## 3.1 Customers

- Confirmed table size and identifier uniqueness.
- No NULL or blank values identified.
- `customer_unique_id` is not one-to-one with `customer_id`;
  multiple customer records can belong to the same customer.
- Customer distribution was profiled by state and city.
- ZIP code range and coverage were reviewed.

**Key observation:** Multiple `customer_id` values can represent the
same `customer_unique_id`. This reflects repeat customer activity
rather than a duplicate-record problem.

---

## 3.2 Orders

- Confirmed table size and `order_id` uniqueness.
- No NULL or blank values identified.
- Order status distribution was reviewed.
- Order purchase date range was established.
- Zero-date values were identified in delivery timestamp fields.
- Order lifecycle timestamps were checked for chronological consistency.
- Delivery dates were compared against order status.

**Key observation:** Zero-date values exist in delivery-related
timestamp fields and require assessment during the data quality phase.

---

## 3.3 Order Items

- Confirmed table size and composite key uniqueness.
- No NULL values identified.
- Shipping limit date range was established.
- Price and freight value ranges were reviewed.
- Referential coverage to orders, products, and sellers was verified.

**Key observation:** No missing parent records were identified
through the relationship checks.

---

## 3.4 Products

- Confirmed table size and `product_id` uniqueness.
- NULL values were profiled.
- Zero values were identified in fields affected by empty values
  during import.
- Product category distribution was reviewed.
- Product weight and dimension ranges were profiled.

**Key observation:** 610 records contain zero values in the
product name length, description length and photo quantity fields.
These correspond to empty values observed during the original import.

---

## 3.5 Sellers

- Confirmed table size and `seller_id` uniqueness.
- NULL and blank values were checked.
- Seller distribution was profiled by state and city.
- ZIP code range and coverage were reviewed.

---

## 3.6 Order Payments

- Confirmed table size.
- NULL values were checked.
- Payment method distribution was profiled.
- Payment value and installment ranges were reviewed.
- Multiple payment records per order were identified.
- Payment records were checked against the orders table.
- Zero and negative payment values were checked.

---

## 3.7 Order Reviews

- Confirmed table size and composite key uniqueness.
- NULL values were profiled.
- Review score range was validated.
- Comment completeness was assessed.
- Review date range was established.
- Review creation and answer timestamps were checked for consistency.

**Key observation:** UTF-8/emoji encoding issues were encountered
during the original data import and should be addressed during
data quality assessment.

---

## 3.8 Geolocation

- Confirmed table size.
- NULL values were checked.
- Latitude and longitude ranges were validated.
- ZIP code coverage was reviewed.
- Duplicate ZIP/city/state combinations were investigated.

**Key observation:** A ZIP code prefix was found associated with
two city names, with one appearing to be a misspelling of the other.
This requires assessment during the data quality phase.

---

## 3.9 Product Category Translation

- Confirmed table size.
- NULL values were checked.
- Category name uniqueness was reviewed.
- Blank values were checked.

**Key observation:** No significant completeness or uniqueness
issues were identified.

---

## Phase 3 Conclusion

The profiling phase established the structural and statistical
characteristics of the dataset and surfaced several conditions
requiring further investigation.

These findings will be carried forward into **Phase 4 —
Data Quality Assessment**, where they will be classified as
valid business behavior, data-quality issues, or items requiring
cleaning and validation.