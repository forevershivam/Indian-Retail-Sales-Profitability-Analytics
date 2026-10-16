# Excel Data Preparation & Dimensional Modeling

**Project:** Indian Retail Sales & Profitability Intelligence  
**Stage:** Completed — Excel data preparation  
**Tools demonstrated:** Microsoft Excel, dynamic arrays, lookup formulas, date functions, source-to-output reconciliation

> **Evidence standard:** This document is based on the original `Indian_Retail_Sales_2023_2025.csv`, the completed six-sheet Excel workbook (`MY WOK.xlsx`), all five exported analytical CSVs, and a record-by-record audit. It describes work visible in the deliverables; it does not claim undocumented VBA, macros, automated refresh, or business outcomes.

## 1. Objective and data flow

Prepare a reliable, order-level retail dataset for SQL analysis and Power BI reporting while separating transaction measures from reusable descriptive attributes.

```text
Original CSV: 139,090 records × 33 columns
    |
    | Remove 1,090 exact duplicate records
    v
Excel Raw_Data: 138,000 unique orders × 33 columns
    |
    | UNIQUE + INDEX/MATCH + XLOOKUP + calendar formulas
    v
Fact_Sales (138,000 × 18)  +  Dim_Customer (39,884 × 8)
                            +  Dim_Product (268 × 5)
                            +  Dim_Employee (24 × 2)
                            +  Dim_Date (1,111 × 6)
    |
    v
Five exported tables → MySQL analysis → Power BI model/reporting
```

**Grain:** One row in `Fact_Sales` represents one unique `Order_ID`, not an aggregated product/category total.

## 2. Cleaning and source preservation

### Exact-duplicate removal

- Original transaction records: **139,090**.
- Exact duplicate rows identified and removed: **1,090**.
- Final retained records: **138,000**, corresponding to **138,000 unique `Order_ID` values**.
- **No unique order was lost.** The final fact export contains every unique source `Order_ID` exactly once.
- All **33 original fields** are retained in `Raw_Data`; the fact table intentionally selects 18 relevant transaction fields.

This is a defensible duplicate-removal claim, not a claim that thousands of unrelated errors or outliers were corrected.

### Date and percentage handling

- `Order_Date` and `Delivery_Date` are represented as Excel date values in the workbook and exported as day-month-year dates.
- **5,937 Cancelled orders** have no delivery date in the original source. The latest cleaned workbook shows blank delivery dates for these orders, and the exported `Fact_Sales.csv` also contains empty values for them.
- Technical nuance: in `Raw_Data` the blank is stored as an Excel empty string; linked `Fact_Sales` formula results are blank, and the SQL import treats the empty exported dates as `NULL`. No fictional delivery dates are assigned.
- Source `Discount_Percent` uses percentage points (for example, `10` means ten percent). Excel displays this as `10%` and stores the proportion as `0.10`. The CSV export displays `10%`; subsequent imports must normalize this format before calculations.
- Currency columns are formatted in INR for presentation. Formatting does not change their economic meaning.

### Avoiding unnecessary source changes

The final exported `Fact_Sales` was compared against the original source for **all 138,000 orders and all 18 matching fields**. After normalizing date formats, currency formatting, and percentage representation, there were **zero mismatched values**. Source-recorded amounts were carried into the fact table rather than silently recomputed or modified.

## 3. Workbook and table design

| Sheet | Data rows | Columns | Role |
|---|---:|---:|---|
| `Raw_Data` | 138,000 | 33 | Cleaned, deduplicated source-level order data |
| `Fact_Sales` | 138,000 | 18 | Transaction facts, order status, sales/cost amounts, and dimension keys |
| `Dim_Customer` | 39,884 | 8 | One row per distinct customer |
| `Dim_Product` | 268 | 5 | One row per distinct product |
| `Dim_Employee` | 24 | 2 | One row per distinct sales employee |
| `Dim_Date` | 1,111 | 6 | Continuous calendar from 2023-01-01 through 2026-01-15 |

The fact table retains `Customer_ID`, `Product_ID` and `Employee_ID` as keys. Names, geography and demographic attributes belong to `Dim_Customer`; category, brand and product details belong to `Dim_Product`; employee names belong to `Dim_Employee`. This avoids repeating descriptive columns in the analytical fact table.

**Order history:** 2023-01-01 through 2025-12-31. The calendar extends into January 2026 so recorded deliveries after the final order date can be accommodated.

## 4. Excel formulas actually present in the workbook

The examples below are simplified only for readability; they reproduce the same Excel techniques and lookup logic found in the saved workbook.

### Dynamic extraction of dimension keys

```excel
=UNIQUE(Raw_Data!$H$2:$H$138001)
```

Used for `Dim_Customer[Customer_ID]`. The same `UNIQUE` technique is used for product, employee, and order keys.

### Attribute lookup using INDEX + two MATCH functions

```excel
=INDEX(
    Raw_Data!$A$2:$AG$138001,
    MATCH($A2, Raw_Data!$H$2:$H$138001, 0),
    MATCH(B$1, Raw_Data!$A$1:$AG$1, 0)
)
```

This retrieves a customer's descriptive attribute by matching **the customer key** and **the requested column header**. Equivalent key-and-header lookups also appear in product and fact preparation.

### Employee lookup using XLOOKUP

```excel
=XLOOKUP(
    $A2,
    Raw_Data!$AC$2:$AC$138001,
    Raw_Data!$AD$2:$AD$138001,
    ,
    0
)
```

Retrieves `Salesman_Name` using the employee ID. The lookup uses an exact match.

### Formula-driven date attributes

```excel
=YEAR($A2)
=MONTH($A2)
=TEXT($A2,"mmmm")
="Q"&ROUNDUP($C2/3,0)
=TEXT($A2,"dddd")
```

The dates themselves form a continuous **1,111-day calendar**; the year, month, quarter and weekday fields are derived for time-based analysis.

### Fact_Sales column mapping

```excel
=INDEX(
    Raw_Data!$A$2:$AG$138001,
    MATCH(Fact_Sales!$A2, Raw_Data!$A$2:$A$138001, 0),
    MATCH(Fact_Sales!B$1, Raw_Data!$A$1:$AG$1, 0)
)
```

This dynamic column-heading match reduces dependency on a hardcoded source column position. The saved workbook has approximately **2.35 million formula cells in `Fact_Sales` alone**; formula-driven transparency is a strength, but repeated lookups at this scale can be computationally expensive.

## 5. Verified quality checks

| Audit check | Result |
|---|---:|
| Exact duplicates removed from source | 1,090 |
| Unique orders retained | 138,000 / 138,000 |
| Missing or repeated fact `Order_ID` values | 0 |
| Fact-to-original field mismatches (18 columns) | 0 |
| Customer-dimension attribute mismatches | 0 |
| Product-dimension attribute mismatches | 0 |
| Employee-dimension attribute mismatches | 0 |
| Fact rows with missing customer/product/employee references | 0 |
| Duplicate dimension keys in exported tables | 0 |
| Cancelled orders with a populated delivery date in export | 0 |
| Invalid gross, discount, or net sales calculations (₹0.02 tolerance) | 0 |
| Inconsistent delivered-order product profit calculations (₹0.02 tolerance) | 0 |
| Formula error-type cells in the saved workbook | 0 |
| Calendar dates missing from the 1,111-day range | 0 |

**Financial validation equations:**

- `Gross_Sales = Quantity × Unit_Price`
- `Discount_Amount = Gross_Sales × Discount_Percent / 100` (percentage-point input)
- `Net_Sales = Gross_Sales − Discount_Amount`
- For **Delivered** orders, recorded `Profit ≈ Net_Sales − Quantity × Unit_Cost`

These are validation rules observed in the provided dataset; they are **not** a claim that the workbook independently recalculates the source-coded revenue/profit columns.

## 6. Business-aware treatment of order status

| Order status | Orders | Revenue treatment | Profit treatment |
|---|---:|---|---|
| Delivered | 126,490 | Include in delivered-sales reporting | Include recorded estimated product profit |
| Returned | 5,573 | Exclude from delivered revenue; analyze separately | Source profit is negative |
| Cancelled | 5,937 | Exclude from delivered revenue; analyze separately | Source profit is zero |

**Delivered-sales reconciliation:** ₹1,551,711,257.30  
**Delivered estimated product profit:** ₹262,956,576.19  
**Delivered estimated product profit margin:** 16.95%

The source stores **positive `Net_Sales` for Returned and Cancelled records**, despite their statuses. Summing all statuses and calling the result realized revenue would overstate delivered-order sales. Recorded `Profit` is an **estimated product contribution**, not audited net profit after all business expenses. Shipping-charge and refund-accounting semantics cannot be established from the source alone.

## 7. What this Excel phase proves—and what it does not

**Demonstrated:** Exact duplicate removal, row-level source preservation, structured fact/dimension construction, `UNIQUE`, `INDEX/MATCH`, `XLOOKUP`, date functions, and data-quality/financial reconciliation.

**Not claimed:** VBA/macros, scheduled or refresh-triggered automation, pivot-based dashboards, measured business impact, forecasting, or a finished Power BI dashboard. Those should only be listed when separately evidenced.

The complete ~60 MB workbook and detailed customer-level CSV files are **not included in this public repository** at this stage. They contain customer names and location attributes and should not be published without a deliberate data-sharing and provenance review. This documentation and the SQL scripts communicate the verified work without exposing row-level personal information.

---

*Audit basis: user-provided original CSV, finalized Excel workbook and five exported dimensional/fact CSVs; verified October 2026. SQL business-question results and Power BI dashboard development are documented separately.*
