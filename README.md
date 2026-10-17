# Indian Retail Sales & Profitability Analytics

**Microsoft Excel | MySQL | Power BI | DAX**

**Project status:** Excel data preparation and SQL analysis complete. Power BI development in progress.

## Project Overview

I started this project with a synthetic Indian retail dataset of **139,090 transaction records across 33 columns**, covering January 2023 to December 2025. The goal was to turn raw transactions into reliable business information and investigate sales performance, profitability, customers, discounts, employees, and sales channels.

I prepared the data and built a fact-and-dimension model in Excel, imported the prepared tables into MySQL, validated the financial figures, and answered six business questions. The next stage is Power BI reporting.

## Key Insights

| Area | Insight |
|------|---------|
| Revenue definition | Adding up every order (all statuses) gives ₹167.15 crore, about ₹12 crore more than the ₹155.17 crore of **Delivered** revenue, because Returned and Cancelled orders also carry positive sales values. |
| Growth | Delivered revenue grew 15.2% (2023 to 2024) and 13.1% (2024 to 2025). Orders grew 12.6% and 10.0%, while average order value grew only 2.3% and 2.8%, so growth is mostly volume-led. |
| Seasonality | October revenue rose 51%, 57% and 72% over September in 2023, 2024 and 2025. In 2025, orders rose about 67% while average order value rose about 3%. |
| Loss-making orders | 1,926 delivered orders (1.52%) were sold below cost, a total of ₹31.4 lakh. None occurred at 0% or 5% discount. Home Appliances and Electronics account for about 99.9% of the loss. |
| Channels | Online channels lose 11.5% of orders to returns and cancellations, versus 3.8% for Retail Store and Corporate Sales. |
| Products | The top 10 products (under 4% of the 268-product catalogue) generate about 19% of estimated profit. |
| Customers | The top 20 customers are all Corporate repeat buyers, but together they contribute only about 1.2% of delivered revenue. |

These are descriptive findings from a synthetic dataset. They do not prove cause and effect.

## 1. Data Preparation in Excel

The original data contained **1,090 exact duplicate records**. After removing them, **138,000 unique orders** remained. I kept the original 33 fields in the cleaned `Raw_Data` sheet and prepared the analytical tables with `UNIQUE`, `INDEX` with `MATCH`, `XLOOKUP`, and date functions.

I validated all 138,000 fact records against the source across 18 fields. After accounting for different date, currency, and percentage formats, the values matched. Customer, product, and employee keys were checked, and all 5,937 cancelled orders have blank delivery dates.

**Documentation:** [Excel Data Preparation](Excel/Data_Preparation.md)

[![Prepared Fact_Sales table in Excel](Screenshots/Excel/02_Fact_Sales.png)](Screenshots/Excel/02_Fact_Sales.png)

## 2. Data Model

The model has one order-level fact table and four dimension tables.

| Table | Records | Purpose |
|-------|--------:|---------|
| `Fact_Sales` | 138,000 | Order quantities, sales, profit, status, and keys |
| `Dim_Customer` | 39,884 | Customer and segment details |
| `Dim_Product` | 268 | Product, category, and brand details |
| `Dim_Employee` | 24 | Sales employee details |
| `Dim_Date` | 1,111 | Calendar attributes for reporting |

[![Power BI model showing the fact table and dimensions](Screenshots/Model/PowerBI_Star_Schema.png)](Screenshots/Model/PowerBI_Star_Schema.png)

Relationships and reporting measures will be reviewed during Power BI development.

**Documentation:** [Data Dictionary](Dataset/Data_Dictionary.md)

## 3. Defining Revenue Correctly

A key issue surfaced during validation: **Returned and Cancelled orders also have positive `Net_Sales` values in the source**. Including them would overstate completed sales, so all financial analysis uses only orders marked **Delivered**. Returns and cancellations are examined separately.

| Verified measure | Value |
|------------------|------:|
| Cleaned orders | 138,000 |
| Delivered orders | 126,490 |
| Returned orders | 5,573 |
| Cancelled orders | 5,937 |
| Customers with at least one Delivered order | 39,043 |
| Delivered revenue | **₹1,551,711,257.30** (₹155.17 crore) |
| Estimated product profit | **₹262,956,576.19** (₹26.30 crore) |
| Estimated product profit margin | **16.95%** |

`Dim_Customer` holds all 39,884 customers; 39,043 of them placed at least one Delivered order. Estimated product profit is a dataset-derived measure, not audited net profit.

## 4. SQL Business Analysis

In MySQL I used joins, CTEs, conditional aggregation, `LAG()`, `DENSE_RANK()`, and running totals to answer six business questions.

| ID | Business question | SQL file |
|----|-------------------|----------|
| BQ 01 | Which 10 products generate the highest estimated profit, and what are their margins and contributions to delivered revenue? | [View query](SQL/BQ_01_Product_Profitability.sql) |
| BQ 02 | Who are the top 20 customers by delivered spending, and how do their order frequency, average order value, and repeat purchase status compare? | [View query](SQL/BQ_02_Customer_Analysis.sql) |
| BQ 03 | How did delivered revenue change month by month, including month-over-month growth and cumulative revenue? | [View query](SQL/BQ_03_Monthly_Sales_Growth.sql) |
| BQ 04 | How do revenue, estimated profit margins, discounts, and average order values vary across discount bands? | [View query](SQL/BQ_04_Discount_Analysis.sql) |
| BQ 05 | How do sales employees rank by delivered revenue and estimated profit, and who performs above or below average revenue? | [View query](SQL/BQ_05_Employee_Performance.sql) |
| BQ 06 | How do sales channels compare on delivered revenue, estimated profit, return rates, and cancellation rates? | [View query](SQL/BQ_06_Channel_Performance.sql) |

### BQ 01: Product Profitability

[![Product profitability result](Screenshots/SQL/BQ_01_Product_Profitability.png)](Screenshots/SQL/BQ_01_Product_Profitability.png)

**Finding:** Wakefit Wooden Bed with Storage ranked first with about ₹61.83 lakh of estimated profit. The top 10 products make up about 10% of delivered revenue but about 19% of estimated profit.

### BQ 02: Customers

**Finding:** The top 20 customers by delivered spending are all Corporate repeat customers. Together they contribute only about 1.2% of delivered revenue, so revenue is not concentrated in a few accounts.

### BQ 03: Monthly Sales Growth

[![Monthly revenue growth result](Screenshots/SQL/BQ_03_Monthly_Growth.png)](Screenshots/SQL/BQ_03_Monthly_Growth.png)

| Year | Delivered orders | Delivered revenue | Average order value |
|------|-----------------:|------------------:|--------------------:|
| 2023 | 37,593 | ₹44.91 crore | ₹11,946 |
| 2024 | 42,323 | ₹51.73 crore | ₹12,223 |
| 2025 | 46,574 | ₹58.53 crore | ₹12,567 |

**Finding:** October 2025 delivered revenue was about ₹7.37 crore, up 71.77% over September. October also rose sharply in 2023 (+50.94%) and 2024 (+56.63%), which suggests a seasonal pattern. The dataset alone does not establish what caused it.

### BQ 04: Discount Analysis

| Discount level | Delivered orders | Estimated margin | Loss-making orders |
|----------------|-----------------:|-----------------:|-------------------:|
| 0% | 38,725 | 21.19% | 0 |
| 5% | 28,855 | 16.29% | 0 |
| 10% | 31,572 | 11.67% | 1,275 |
| 15% | 15,115 | 17.73% | 570 |
| 20% | 9,090 | 20.95% | 77 |
| 25% | 3,133 | 19.72% | 4 |

**Finding:** Margin does not fall steadily as discounts rise. It is lowest at the 10% level and highest with no discount. Orders without a discount made 31% of delivered revenue but 39% of estimated profit.

Note: discounts in this dataset come in steps of 5%, so the SQL labels "6-10%" and "Above 20%" contain only 10% and 25% orders.

### BQ 05: Employee Performance

**Finding:** 17 of 24 employees are above the company average delivered revenue (₹6.47 crore). The top employee sells about 2.5 times as much as the lowest, mainly through order volume. Rankings differ by measure: Rohit Majhi ranks 5th by revenue but 1st by estimated profit.

### BQ 06: Sales Channel Performance

[![Sales channel performance result](Screenshots/SQL/BQ_06_Sales_Channel.png)](Screenshots/SQL/BQ_06_Sales_Channel.png)

| Channel | Revenue share | Margin | Return rate | Cancellation rate |
|---------|--------------:|-------:|------------:|------------------:|
| Retail Store | 30.02% | 17.83% | 2.58% | 1.05% |
| Corporate Sales | 23.96% | 15.00% | 1.77% | 2.48% |
| Marketplace | 16.93% | 16.93% | 5.27% | 7.53% |
| Mobile App | 14.71% | 18.15% | 5.23% | 5.70% |
| Website | 14.39% | 17.13% | 5.04% | 5.64% |

**Finding:** Retail Store contributes the most delivered revenue, and Marketplace has the highest cancellation rate. Online channels together lose 11.54% of orders to returns and cancellations, versus 3.78% for Retail Store and Corporate Sales. Corporate Sales is about 10% of delivered orders but 24% of delivered revenue, with an average order of roughly ₹29,300 and the lowest margin.

## 5. Loss-Making Orders

Beyond the six questions, I checked which delivered orders were sold below cost. **1,926 orders (1.52%)** had negative estimated profit, totalling about **₹31.42 lakh**.

| Category | Delivered orders | Loss-making orders | Share of orders | Total loss |
|----------|-----------------:|-------------------:|----------------:|-----------:|
| Home Appliances | 12,695 | 1,003 | 7.90% | ₹20.76 lakh |
| Electronics | 31,335 | 883 | 2.82% | ₹10.64 lakh |
| Other categories | 82,460 | 40 | under 0.1% | about ₹0.01 lakh |

Home Appliances and Electronics account for about 97.9% of loss-making orders and 99.95% of the total loss. Loss-making orders appear only at discounts of 10% and above.

To understand why, I compared margins **before** discounts:

| Category | Margin before discount |
|----------|-----------------------:|
| Home Appliances | 16.39% |
| Groceries & FMCG | 17.10% |
| Electronics | 17.67% |
| Toys & Baby | 29.27% |
| Books & Stationery | 32.66% |
| Furniture | 33.63% |
| Sports & Fitness | 35.78% |
| Fashion | 45.31% |
| Beauty & Personal Care | 45.74% |

**Finding:** An order loses money when its discount is larger than its own pre-discount margin. Home Appliances and Electronics start with the thinnest margins, so discounts of 10% or more push many of their orders below cost. Fashion and Beauty have no loss-making orders. Groceries & FMCG has a similarly thin margin but only 6 loss-making orders. This is an observed pattern, and pricing and product costs would need further review to confirm causes.

## 6. Recommendations to Investigate

- **Pricing and discounts:** Review product-level costs and discount rules for Home Appliances and Electronics, where discounts of 10% or more push orders below cost.
- **Online channels:** Investigate the reasons behind Marketplace cancellations (7.53%) and online returns before making operational changes.
- **Seasonal planning:** Study the repeated October increase and whether inventory and staffing plans should reflect it.
- **Revenue reporting:** Keep reporting revenue on Delivered orders only, since returned and cancelled orders carry positive sales values.

These are suggestions for further analysis, not claims of verified commercial impact.

## 7. Next Stage: Power BI

| Completed | In progress |
|-----------|-------------|
| Excel cleaning and fact/dimension preparation | Power BI model verification |
| Data validation and reconciliation | DAX measures and interactive dashboards |
| Six MySQL business analyses and loss-making order analysis | Dashboard screenshots and final report |
| Excel documentation and data dictionary | Final business recommendations |

Dashboard screenshots and the final report will be added once they are completed and reviewed.

## 8. Dataset and Reproducibility

This project uses a **synthetic practice dataset created for portfolio learning**. All names, locations, and transactions are fictional. The repository shares the documented preparation workflow, data dictionary, six SQL files, and screenshots of the results. The complete row-level dataset is not included, because the original generated dataset's public redistribution rights have not been independently established. To run the SQL files, load the corresponding prepared fact and dimension tables into MySQL 8 or later.

**[View all project screenshots](Screenshots/README.md)** | **Author:** [forevershivam](https://github.com/forevershivam)
