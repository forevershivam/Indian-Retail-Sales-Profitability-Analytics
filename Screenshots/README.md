# Project Evidence Gallery

These screenshots document the Excel preparation, analytical model, and executed MySQL results used in this portfolio project. The screenshots reflect the current completed stages. The final Power BI dashboard is still in development.

Some original images displayed customer or employee names. Those names have been covered before publishing to this public repository. The recorded calculations, row counts, and other analysis values have not been altered.

## Excel preparation

| Screenshot | What it demonstrates |
|:--|:--|
| [Cleaned Raw Data](Excel/01_Cleaned_Raw_Data.png) | Deduplicated order data with the original source fields retained. Customer names are hidden. |
| [Fact Sales](Excel/02_Fact_Sales.png) | Order level fact table with keys, order status, prices, discounts, and revenue. |
| [Customer Dimension](Excel/03_Customer_Dimension.png) | Customer attributes and segment fields. Names are hidden. |
| [Product Dimension](Excel/04_Product_Dimension.png) | Product master fields including category, subcategory, and brand. |
| [Employee Dimension](Excel/05_Employee_Dimension.png) | Employee lookup structure. Names are hidden. |
| [Date Dimension](Excel/06_Date_Dimension.png) | Year, month, quarter, and weekday attributes generated from the calendar. |

## Analytical model

![Power BI data model](Model/PowerBI_Star_Schema.png)

The model view shows the existing relationships between the order fact table and four dimensions. Final Power BI relationship settings will be reviewed during dashboard development.

## MySQL analysis results

| Business question | Screenshot |
|:--|:--|
| BQ 01: Product profitability | [Top products and estimated profit](SQL/BQ_01_Product_Profitability.png) |
| BQ 02: Customer analysis | [Top customers, repeat status, and spending](SQL/BQ_02_Customer_Analysis.png) |
| BQ 03: Monthly growth | [Monthly revenue, month over month growth, and cumulative revenue](SQL/BQ_03_Monthly_Growth.png) |
| BQ 04: Discounts | [Revenue and profit by discount level](SQL/BQ_04_Discount_Profitability.png) |
| BQ 05: Employee performance | [Sales and profit employee rankings](SQL/BQ_05_Employee_Performance.png) |
| BQ 06: Sales channels | [Channel revenue, returns, and cancellations](SQL/BQ_06_Sales_Channel.png) |

The customer and employee name columns in BQ 02 and BQ 05 have been hidden for publication. All six analysis questions have corresponding SQL scripts in the [SQL folder](../SQL/).

## Final SQL validation

[View the delivered revenue and estimated profit reconciliation](SQL/Final_Reconciliation_Check.png)

This screenshot confirms 126,490 delivered orders, ₹1,551,711,257.30 in delivered revenue, and ₹262,956,576.19 in estimated product profit. It is a validation check, not a seventh business question.
