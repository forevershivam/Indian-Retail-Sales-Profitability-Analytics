# Data Dictionary & Analytical Model

**Project:** Indian Retail Sales & Profitability Intelligence  
**Dataset period:** Order dates 2023-01-01 to 2025-12-31  
**Data lineage:** Original 33-column retail CSV → cleaned `Raw_Data` → five exported analytical tables  
**Status:** Verified against the original CSV, user workbook, and exported CSV values.

## 1. Source and model scope

| Dataset/table | Data rows | Fields | Grain / purpose |
|---|---:|---:|---|
| Original CSV | 139,090 | 33 | Raw records, including 1,090 exact duplicates |
| `Raw_Data` | 138,000 | 33 | Deduplicated source records, one per `Order_ID` |
| `Fact_Sales` | 138,000 | 18 | Unique order-level fact row |
| `Dim_Customer` | 39,884 | 8 | Unique `Customer_ID` |
| `Dim_Product` | 268 | 5 | Unique `Product_ID` |
| `Dim_Employee` | 24 | 2 | Unique `Employee_ID` |
| `Dim_Date` | 1,111 | 6 | Unique calendar date, 2023-01-01 to 2026-01-15 |

**Logical data types below are recommended modeling types.** The original, Excel workbook, exported CSV, MySQL and Power BI can store/display the same field differently. For example, exported currency strings such as `₹ 1,000.00` require normalization before numeric SQL import.

## 2. All 33 original source fields

| Field | Logical type | Analytical destination | Definition / rule |
|---|---|---|---|
| `Order_ID` | Text (key) | Fact_Sales | Unique order identifier after deduplication; must not be null or repeated. |
| `Order_Date` | Date | Fact_Sales, Dim_Date relationship | Date the order was recorded; not the delivery date. |
| `Order_Month` | Text | Raw_Data only | Source month name; analytically use Dim_Date to avoid redundant fact attributes. |
| `Order_Year` | Integer | Raw_Data only | Source calendar year; analytically use Dim_Date. |
| `Quarter` | Text | Raw_Data, derived in Dim_Date | Calendar quarter label, e.g., Q1. |
| `Order_Status` | Text | Fact_Sales | `Delivered`, `Returned` or `Cancelled`; controls revenue inclusion. |
| `Sales_Channel` | Text | Fact_Sales | Retail Store, Corporate Sales, Marketplace, Mobile App or Website. |
| `Customer_ID` | Text (FK) | Fact_Sales, Dim_Customer | Stable customer relationship key. |
| `Customer_Name` | Text | Dim_Customer | Recorded display name; potentially personally identifying. |
| `Gender` | Text | Dim_Customer | Recorded source label; not inferred. |
| `Customer_Age` | Integer | Dim_Customer | Age in source; not automatically current age. |
| `Customer_Segment` | Text | Dim_Customer | Recorded segment, including Consumer and Corporate. |
| `City` | Text | Dim_Customer | Recorded city. |
| `State` | Text | Dim_Customer | Recorded state. |
| `Region` | Text | Dim_Customer | Business-assigned geographical grouping. |
| `Product_ID` | Text (FK) | Fact_Sales, Dim_Product | Product relationship key. |
| `Product_Name` | Text | Dim_Product | Recorded product label. |
| `Category` | Text | Dim_Product | Major product category. |
| `Subcategory` | Text | Dim_Product | Product subcategory. |
| `Brand` | Text | Dim_Product | Brand label from source. |
| `Quantity` | Integer | Fact_Sales | Units associated with the order. |
| `Unit_Price` | Decimal, INR | Fact_Sales | Selling/list price per unit before discount. |
| `Unit_Cost` | Decimal, INR | Fact_Sales | Recorded product cost per unit; excludes unverified overhead costs. |
| `Gross_Sales` | Decimal, INR | Fact_Sales | `Quantity × Unit_Price`. |
| `Discount_Percent` | Percentage | Fact_Sales | Original CSV uses percentage points (`10` = 10%); Excel stores 0.10, displays 10%; MySQL calculations must use the imported scale. |
| `Discount_Amount` | Decimal, INR | Fact_Sales | `Gross_Sales × discount rate`. |
| `Net_Sales` | Decimal, INR | Fact_Sales | `Gross_Sales − Discount_Amount`; **not automatically recognized revenue** for every order status. |
| `Profit` | Decimal, INR | Fact_Sales | Source-recorded status-dependent estimated profit. Delivered rows equal `Net_Sales − Quantity×Unit_Cost` within rounding tolerance. |
| `Employee_ID` | Text (FK) | Fact_Sales, Dim_Employee | Salesperson relationship key. |
| `Salesman_Name` | Text | Dim_Employee | Sales employee name from source. |
| `Payment_Mode` | Text | Fact_Sales | Recorded payment method; not proof of cash settlement. |
| `Shipping_Charge` | Decimal, INR | Fact_Sales | Recorded shipping charge; whether this is revenue, cost or pass-through is not established. |
| `Delivery_Date` | Date / null | Fact_Sales | Recorded delivery/return-associated date; empty for all 5,937 Cancelled orders. |

## 3. Dim_Date: six fields

| Field | Logical type | Rule |
|---|---|---|
| `Date` | Date (unique key) | Every calendar date from 2023-01-01 to 2026-01-15, inclusive. |
| `Year` | Integer | `YEAR(Date)` |
| `Month_Num` | Integer | `MONTH(Date)`, from 1 to 12 |
| `Month_Name` | Text | Full month name, generated with `TEXT(Date,"mmmm")` |
| `Quarter` | Text | `"Q"&ROUNDUP(Month_Num/3,0)` |
| `Weekday` | Text | Full weekday name, generated with `TEXT(Date,"dddd")` |

For correct chronological visualization, sort `Month_Name` by `Month_Num` (and use both year and month when charting more than one year).

## 4. Model keys and relationships

| Dimension (unique side) | Fact foreign key | Intended cardinality |
|---|---|---|
| `Dim_Customer[Customer_ID]` | `Fact_Sales[Customer_ID]` | 1-to-many |
| `Dim_Product[Product_ID]` | `Fact_Sales[Product_ID]` | 1-to-many |
| `Dim_Employee[Employee_ID]` | `Fact_Sales[Employee_ID]` | 1-to-many |
| `Dim_Date[Date]` | `Fact_Sales[Order_Date]` | 1-to-many |

The existing Power BI model screenshot shows four dimension-to-fact relationships. Exact date-relationship activation and final data types should be verified in Power BI Desktop before the dashboard is finalized. `Delivery_Date` is a second date role; reporting by it needs an explicit relationship strategy rather than assuming it uses the `Order_Date` relationship.

**Model screenshot:** [Power BI fact and dimension relationships](../Screenshots/Model/PowerBI_Star_Schema.png). This is the existing model view; final reporting relationships and DAX measures are still under development.

## 5. Data integrity and reconciliation rules

| Validation | Verified result |
|---|---|
| Deduplicated rows | 139,090 original − 1,090 exact duplicates = 138,000 |
| Unique fact IDs | 138,000 / 138,000 |
| Fact field-level differences vs source after representation normalization | 0, across all 18 matching fields and all orders |
| Customer, product and employee dimension attribute differences vs source | 0 |
| Missing customer/product/employee fact references | 0 |
| Duplicate dimension IDs in exports | 0 |
| Missing dates in Dim_Date calendar range | 0 |
| Cancelled orders with populated delivery date in fact export | 0 |
| Invalid gross/discount/net equations (₹0.02 tolerance) | 0 |
| Invalid delivered profit equations (₹0.02 tolerance) | 0 |

**Source-recorded status distribution:** Delivered **126,490**, Returned **5,573**, Cancelled **5,937**.

### Revenue and profit definitions

The source stores positive `Net_Sales` values even when an order is marked Returned or Cancelled. For this reason, the delivered revenue measure includes only rows with `Order_Status = 'Delivered'`.

| Delivered order metric | Verified result |
|:--|--:|
| `SUM(Net_Sales)` | **₹1,551,711,257.30** |
| `SUM(Profit)` | **₹262,956,576.19** |
| Estimated product profit margin | **16.95%** |

The source records negative `Profit` values for returned orders and zero `Profit` for cancelled orders. No separate refund ledger is available in the provided tables. The `Profit` field should therefore be described as estimated product profit, not audited business net profit. Likewise, shipping charges cannot be assumed to represent a specific fulfillment cost or revenue treatment without further context.

## 6. Source files, formats and limitations

The original source is `Indian_Retail_Sales_2023_2025.csv`. The audited Excel workbook, `MY WOK.xlsx`, contains the cleaned `Raw_Data` sheet, `Fact_Sales`, and four dimension sheets. Five CSV files were exported from the fact and dimension tables for further analysis.

Exported dates use `DD-MM-YYYY` formatting, monetary values use INR formatting, and discount values are displayed as percentages. Before importing the files to MySQL, those representations need to be parsed as dates and numeric values.

It has not been independently verified whether the dataset represents a real company or a synthetic practice scenario. Accordingly, the project does not claim verified commercial results or measurable changes in an actual business.

Customer and employee names and location fields are excluded from this public repository. Publishing individual records would require an appropriate review of privacy and data sharing rights.

See [Excel Data Preparation](../Excel/Data_Preparation.md) for the cleaning workflow, workbook formulas and audit evidence.
