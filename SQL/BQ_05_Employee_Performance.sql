WITH Employee_Performance AS (
    SELECT
        e.Employee_ID,
        e.Salesman_Name,

        COUNT(DISTINCT f.Order_ID) AS Total_Orders,

        SUM(f.Quantity) AS Units_Sold,

        ROUND(SUM(f.Net_Sales), 2) AS Total_Revenue,

        ROUND(SUM(f.Profit), 2) AS Total_Profit,

        ROUND(
            SUM(f.Net_Sales) /
            NULLIF(COUNT(DISTINCT f.Order_ID), 0),
            2
        ) AS Average_Order_Value,

        ROUND(
            SUM(f.Profit) * 100.0 /
            NULLIF(SUM(f.Net_Sales), 0),
            2
        ) AS Profit_Margin_Percent

    FROM fact_sales f

    INNER JOIN dim_employee e
        ON f.Employee_ID = e.Employee_ID

    WHERE f.Order_Status = 'Delivered'

    GROUP BY
        e.Employee_ID,
        e.Salesman_Name
),

Employee_Ranking AS (
    SELECT
        ep.*,

        DENSE_RANK() OVER (
            ORDER BY ep.Total_Revenue DESC
        ) AS Revenue_Rank,

        DENSE_RANK() OVER (
            ORDER BY ep.Total_Profit DESC
        ) AS Profit_Rank,

        ROUND(
            AVG(ep.Total_Revenue) OVER (),
            2
        ) AS Company_Avg_Employee_Revenue,

        ROUND(
            ep.Total_Revenue * 100.0 /
            NULLIF(SUM(ep.Total_Revenue) OVER (), 0),
            2
        ) AS Revenue_Contribution_Percent

    FROM Employee_Performance ep
)

SELECT
    Employee_ID,
    Salesman_Name,
    Total_Orders,
    Units_Sold,
    Total_Revenue,
    Total_Profit,
    Average_Order_Value,
    Profit_Margin_Percent,
    Revenue_Contribution_Percent,
    Revenue_Rank,
    Profit_Rank,
    Company_Avg_Employee_Revenue,

    CASE
        WHEN Total_Revenue > Company_Avg_Employee_Revenue
            THEN 'Above Average'

        WHEN Total_Revenue < Company_Avg_Employee_Revenue
            THEN 'Below Average'

        ELSE 'At Average'
    END AS Performance_Status

FROM Employee_Ranking

ORDER BY Revenue_Rank, Employee_ID;
