WITH Monthly_Sales AS (
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        COUNT(*) AS Total_Orders,
        SUM(Net_Sales) AS Monthly_Revenue
    FROM fact_sales
    WHERE Order_Status = 'Delivered'
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),

Sales_Comparison AS (
    SELECT
        Sales_Year,
        Sales_Month,
        Total_Orders,
        Monthly_Revenue,

        LAG(Monthly_Revenue) OVER (
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Revenue,

        SUM(Monthly_Revenue) OVER (
            ORDER BY Sales_Year, Sales_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Cumulative_Revenue

    FROM Monthly_Sales
)

SELECT
    Sales_Year,
    Sales_Month,
    Total_Orders,

    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,

    ROUND(Previous_Month_Revenue, 2)
        AS Previous_Month_Revenue,

    ROUND(
        (Monthly_Revenue - Previous_Month_Revenue)
        * 100.0 / NULLIF(Previous_Month_Revenue, 0),
        2
    ) AS MoM_Growth_Percent,

    ROUND(Cumulative_Revenue, 2) AS Cumulative_Revenue

FROM Sales_Comparison
ORDER BY Sales_Year, Sales_Month;
