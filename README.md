# Indian Retail Sales & Profitability Intelligence

**Tools:** Microsoft Excel, MySQL, Power BI and DAX  
**Current status:** Excel preparation and SQL analysis completed. Power BI reporting is in progress.

This project explores the sales and profitability performance of an Indian retail dataset covering January 2023 to December 2025. I prepared the transaction data in Excel, built a fact and dimension structure, validated the results in MySQL, and answered six business questions using SQL.

The next stage is to develop interactive Power BI reports with measures that respond to filters and help examine business performance from different perspectives.

## Business objective

The analysis focuses on finding profitable products, understanding repeat purchasing, evaluating monthly growth, examining discount patterns, comparing sales employee performance, and identifying operational differences between sales channels.

A key reporting decision is to separate delivered orders from returned and cancelled orders. Although the source contains positive net sales values for every status, only delivered orders are included in the delivered revenue and estimated profit KPIs.

## Dataset overview

| Metric | Verified value |
|:--|--:|
| Original records | 139,090 |
| Exact duplicate records removed | 1,090 |
| Cleaned, unique orders | 138,000 |
| Original fields | 33 |
| Delivered orders | 126,490 |
| Returned orders | 5,573 |
| Cancelled orders | 5,937 |
| Customers in the customer dimension | 39,884 |
| Customers with at least one delivered order | 39,043 |
| Products | 268 |
| Sales employees | 24 |
| Sales channels | 5 |

### Verified sales figures

| KPI | Result |
|:--|--:|
| Delivered revenue | ₹1,551,711,257.30 |
| Estimated product profit on delivered orders | ₹262,956,576.19 |
| Estimated product profit margin | 16.95% |

These results are calculated from **126,490 delivered orders**. The recorded profit represents estimated product profit, not audited net profit after all operating expenses.

## Excel data preparation

The source contained 139,090 records, including 1,090 exact duplicates. After removing those duplicates, 138,000 unique orders remained. All 33 original source fields were retained in the cleaned `Raw_Data` sheet.

I prepared an order level `Fact_Sales` table with 18 fields and four dimensions for customers, products, employees, and dates. The Excel workbook uses `UNIQUE`, `INDEX` with `MATCH`, `XLOOKUP`, and date formulas to populate the analytical tables.

The exported fact table was compared against the original source. All 138,000 orders and their 18 corresponding fact fields matched after normalizing date, currency, and percentage formats. The dimension tables were also checked against the source, with no missing customer, product, or employee references.

For cancelled orders, the delivery date remains blank rather than being assigned an artificial date.

**Full documentation:** [Excel Data Preparation](Excel/Data_Preparation.md)

## Analytical data model

| Table | Records | Fields | Purpose |
|:--|--:|--:|:--|
| `Fact_Sales` | 138,000 | 18 | Order details, amounts, status, and dimension keys |
| `Dim_Customer` | 39,884 | 8 | Customer attributes and geography |
| `Dim_Product` | 268 | 5 | Product details, categories, and brands |
| `Dim_Employee` | 24 | 2 | Sales employee details |
| `Dim_Date` | 1,111 | 6 | Calendar dates from January 2023 to January 2026 |

Each dimension is designed to connect to `Fact_Sales` through its corresponding key. The final Power BI relationship settings will be reviewed as part of the dashboard stage.

**Field definitions and validation rules:** [Data Dictionary](Dataset/Data_Dictionary.md)

## SQL business analysis

The prepared tables were imported into MySQL. SQL analysis uses joins, common table expressions, conditional aggregation, and window functions such as `LAG()` and `DENSE_RANK()`.

**Six business questions have been completed:**

| Question | Analysis | SQL query |
|:--|:--|:--|
| BQ 01 | Which products contribute the highest estimated profit? | [Product Profitability](SQL/BQ_01_Product_Profitability.sql) |
| BQ 02 | Who are the highest value customers and repeat buyers? | [Customer Analysis](SQL/BQ_02_Customer_Analysis.sql) |
| BQ 03 | How has monthly delivered revenue changed over time? | [Monthly Sales Growth](SQL/BQ_03_Monthly_Sales_Growth.sql) |
| BQ 04 | How does profitability differ between discount bands? | [Discount Analysis](SQL/BQ_04_Discount_Analysis.sql) |
| BQ 05 | Which employees lead in revenue and estimated profit? | [Employee Performance](SQL/BQ_05_Employee_Performance.sql) |
| BQ 06 | How do sales channels compare in revenue, returns, and cancellations? | [Channel Performance](SQL/BQ_06_Channel_Performance.sql) |

The additional reconciliation query used during validation is not counted as a business question.

### Findings from the SQL results

| Focus area | Finding |
|:--|:--|
| Product profitability | Wakefit Wooden Bed with Storage ranked first by estimated profit at approximately ₹61.83 lakh. |
| Customer behavior | All 20 customers in the highest revenue ranking were repeat customers from the Corporate segment. |
| Monthly growth | October 2025 recorded approximately ₹7.37 crore in delivered revenue, with 71.77% growth over September. |
| Discounts | The no discount group had a 21.19% estimated profit margin, compared with 11.67% for the 6% to 10% discount group. |
| Employee performance | The highest revenue ranked salesperson generated approximately ₹8.27 crore of delivered revenue. |
| Sales channels | Retail Store accounted for 30.02% of delivered revenue. Marketplace recorded a 7.53% cancellation rate. |

The discount results are comparisons between groups, not proof that discounts caused a particular profit outcome. Return and cancellation rates are based on the recorded order statuses.

## Power BI development

The Power BI stage is still being worked on. The next tasks are to verify the model relationships, create DAX measures, answer six additional reporting questions, and build interactive dashboard pages.

Dashboard screenshots and the finished Power BI report will be added only after they are complete and checked.

| Project stage | Status |
|:--|:--|
| Excel data preparation and validation | Completed |
| MySQL validation and six business questions | Completed |
| Excel preparation documentation and data dictionary | Completed |
| Power BI model review, DAX, and dashboards | In progress |
| Final dashboard presentation and consolidated recommendations | Pending |

## Repository contents

| Folder or file | Contents |
|:--|:--|
| [Excel](Excel/) | Documented cleaning steps, formulas, checks, and data preparation |
| [Dataset](Dataset/) | Data dictionary, field definitions, and modeling rules |
| [SQL](SQL/) | Six completed business question queries |
| `README.md` | Project overview, current findings, and status |

The SQL scripts require MySQL 8 or later and the prepared tables to be loaded first. The repository currently contains the analysis queries and documentation, not a database dump or an automatic setup script.

## Data availability

The complete workbook and row level datasets are not publicly included because they contain customer and employee names along with location details. Publishing them requires a separate review of data privacy and sharing rights.

This is a portfolio analysis project. The figures describe the supplied dataset and should not be presented as audited company financial statements or independently verified commercial results.

**GitHub:** [forevershivam](https://github.com/forevershivam)
