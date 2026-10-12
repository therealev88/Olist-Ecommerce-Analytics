# Phase 7 – Exploratory Data Analysis

## 1. Objective

Explore the cleaned Olist dataset to identify meaningful patterns in sales, orders, fulfillment, customers, products, sellers, payments, customer experience, geography, and cross-domain relationships.

The analysis uses the cleaned tables produced in Phase 5 and validated in Phase 6. No source data was modified during EDA.

## 2. Dataset Overview

The cleaned dataset contains:

- 99,441 orders
- 112,650 order items
- 32,951 products
- 99,441 customers
- 3,095 sellers
- 103,886 payment records
- 99,223 reviews

The dataset covers activity from September 2016 through October 2018, with partial observations at the beginning and end of the period.

## 3. Sales & Order Trends

Order activity increased substantially from 2017 into 2018.

- Monthly orders grew from 800 in January 2017 to 4,631 in October 2017.
- November 2017 recorded the highest full-period monthly volume at 7,544 orders and approximately R$1.19M in recorded payment value.
- Monthly order volume remained high through 2018, reaching 7,269 orders in January and 7,211 in March.
- Average order value generally remained within approximately R$150–R$170 during the main operating period.

The increase in recorded payment value was therefore driven primarily by growth in order volume rather than a major increase in order size.

The September and October 2018 observations are very small and should not be interpreted as evidence of a business decline.

## 4. Order Status & Fulfillment

Delivered orders dominate the dataset:

- Delivered: 96,478 orders (97.02%)
- Shipped: 1,107 (1.11%)
- Canceled: 625 (0.63%)
- Unavailable: 609 (0.61%)

Among delivered orders with usable delivery timestamps:

- Average delivery time was 12.09 days.
- Delivery time ranged from 0 to 209 days.
- 91.89% were delivered on or before the estimated date.
- 8.11% were delivered late.
- Late deliveries averaged 8.87 days beyond the estimated date.

Delivery performance varied considerably by month. Several periods showed strong on-time performance above 94%, while March 2018 fell to 78.64%. June 2018 subsequently reached 98.64%.

Canceled and unavailable orders together represented 1.24% of all orders.

## 5. Customer Analysis

Customer purchasing was heavily concentrated among one-time buyers.

- 96.88% of customers placed one order.
- 3.12% were repeat customers.
- Among repeat customers, 91.59% placed exactly two orders.
- Only 48 repeat customers placed five or more orders.
- One customer placed 17 orders.

Customer geography was highly concentrated:

- São Paulo accounted for 41.92% of customers.
- Rio de Janeiro accounted for 12.88%.
- Minas Gerais accounted for 11.71%.
- The three states together represented approximately 66.51% of customers.

Customer share and order share were closely aligned, indicating that geographic concentration was not primarily driven by unusually high purchase frequency in individual states.

## 6. Products & Categories

Product demand was concentrated in several major categories.

Leading categories by order volume included:

- Bed/Bath/Table
- Health/Beauty
- Sports/Leisure
- Computers/Accessories
- Furniture/Decor
- Housewares
- Watches/Gifts

Category volume and category value were not identical. Health/Beauty led recorded item value among major categories, while Watches/Gifts generated high value with fewer orders because of its higher average product prices.

Product-level analysis also showed that high unit volume does not necessarily imply high total value. Some lower-volume products generated substantial value because of higher prices.

Computers had the highest average product price among categories meeting the minimum sample threshold, while high-volume categories such as Bed/Bath/Table, Housewares, and Furniture/Decor generally had lower average prices.

## 7. Seller Analysis

Seller performance varied substantially.

High order volume did not necessarily correspond to high item value. Some sellers handled many relatively low-value orders, while others generated substantial value from considerably fewer orders.

São Paulo dominated the seller network:

- 1,849 of 3,095 sellers were located in São Paulo.
- São Paulo therefore accounted for approximately 59.74% of sellers.

Seller geography was more concentrated than customer geography.

Seller productivity also varied by state. Bahia and Pernambuco showed high value per seller, but their small seller populations mean these results should be interpreted cautiously.

## 8. Payment Analysis

Credit cards were the dominant payment method:

- Credit card: 76,795 payment records and approximately R$12.54M in recorded payment value.
- Boleto: 19,784 records and approximately R$2.87M.
- Voucher: 5,775 records and approximately R$379K.
- Debit card: 1,529 records and approximately R$218K.

Credit cards were used in 76.94% of orders, while boleto appeared in 19.90%. These percentages can exceed a simple 100% total because an order may contain multiple payment records or methods.

Credit-card installment behavior showed a clear association between longer installment plans and higher payment values. One-installment payments were the largest group, while higher installment ranges generally had higher average payment values.

## 9. Reviews & Customer Experience

Customer reviews were predominantly positive:

- 5 stars: 57.78%
- 4 stars: 19.29%
- 3 stars: 8.24%
- 2 stars: 3.18%
- 1 star: 11.51%

Overall, 77.07% of reviews were rated 4 or 5 stars.

Delivery performance showed the strongest relationship with customer satisfaction observed during EDA.

- On-time deliveries averaged 4.29/5.
- Late deliveries averaged 2.57/5.
- Delivery delays showed a further decline in satisfaction:
  - On time: 4.29
  - 1–3 days late: 3.29
  - 4–7 days late: 2.10
  - 8–14 days late: 1.68
  - 15+ days late: 1.72

Order status also aligned strongly with satisfaction. Delivered orders averaged 4.16, while incomplete or problematic statuses generally had substantially lower scores.

Payment method showed little meaningful difference in review scores. The major payment methods ranged from approximately 4.00 to 4.17.

Negative reviewers were much more likely to leave written comments:

- 5-star reviews: 35.84% included comments.
- 1-star reviews: 76.55% included comments.

This suggests that written review content is particularly valuable for understanding dissatisfaction.

Higher-value orders also showed slightly lower average review scores:

- Under R$50: 4.18
- R$50–99: 4.13
- R$100–199: 4.08
- R$200–499: 3.98
- R$500+: 3.88

These relationships are observational associations and do not establish causation.

## 10. Geographic Analysis

The marketplace showed strong geographic concentration and substantial interstate activity.

The largest seller-to-customer route was:

- São Paulo → São Paulo: 31,502 orders and approximately R$4.10M in item value.

Major interstate routes included São Paulo to Rio de Janeiro and São Paulo to Minas Gerais.

Overall:

- Interstate orders: 63,313 (64.01%)
- In-state orders: 35,600 (35.99%)

Interstate orders represented approximately 69.72% of item value.

Average item value per order was also higher for interstate commerce:

- In-state: R$134.76
- Interstate: R$174.47

This represents an approximately 29.5% higher average value for interstate orders.

## 11. Cross-Domain Analysis

Cross-domain analysis combined operational, commercial, product, seller, and customer-experience measures.

### Delivery Performance and Order Value

Late orders had a higher average order value than on-time orders:

- On time: R$158.72
- Late: R$172.73

The difference was approximately 8.8%. This is a modest association compared with the much stronger relationship between delivery performance and review scores.

### Product Category and Customer Satisfaction

Average review scores varied considerably by category.

Examples included:

- Office Furniture: 3.52
- Bed/Bath/Table: 3.92
- Computers/Accessories: 3.99
- Health/Beauty: 4.19
- Pet Shop: 4.22
- Luggage/Accessories: 4.35

Category-level satisfaction therefore cannot be explained by delivery performance alone.

### Category Satisfaction and Delivery Performance

Low satisfaction sometimes coincided with higher late-delivery rates, but the relationship was not universal.

For example, Office Furniture had a 3.52 average review score and a 9.00% late rate, while Electronics had a higher 9.81% late rate but still averaged 4.07.

This indicates that delivery performance is an important marketplace-wide satisfaction factor, while product-specific and other factors also contribute to customer experience.

### Seller Volume and Customer Satisfaction

Seller order volume showed little meaningful relationship with review scores.

Average seller review scores ranged from 3.96 among sellers with fewer than 50 orders to approximately 4.02–4.07 among higher-volume groups.

There was no consistent increase or decrease in satisfaction as seller volume increased.

## 12. Key Findings & Conclusion

Phase 7 identified several major patterns:

1. **Marketplace activity expanded rapidly**, with order growth driving most of the increase in recorded payment value.
2. **Delivery performance is a major customer-experience factor.** Late deliveries were strongly associated with lower review scores, and satisfaction declined sharply as delays increased.
3. **The marketplace has a strong one-time customer profile**, with only 3.12% of customers classified as repeat purchasers.
4. **Customer and seller activity is geographically concentrated**, particularly in São Paulo and other major states.
5. **Interstate commerce dominates the marketplace**, accounting for 64.01% of orders and approximately 69.72% of item value.
6. **Product category influences both commercial performance and customer satisfaction**, with substantial variation across categories.
7. **Payment method has relatively little relationship with customer satisfaction** compared with fulfillment performance.
8. **High seller volume does not appear to guarantee higher customer satisfaction.**
9. **Negative reviews contain a disproportionate amount of written feedback**, making review comments especially valuable for subsequent qualitative analysis.

Overall, the EDA shows that **fulfillment performance—particularly delivery timeliness—is one of the clearest operational factors associated with customer satisfaction**, while customer behavior, geography, product category, and seller characteristics create additional layers of variation.

No causal conclusions are drawn from these exploratory relationships. The findings provide the analytical foundation for the next phase of the project.
