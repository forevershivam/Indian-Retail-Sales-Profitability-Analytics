WITH Discount_Analysis AS (
    SELECT
        CASE
            WHEN Discount_Percent = 0
                THEN 'No Discount'
            WHEN Discount_Percent <= 0.05
                THEN '1-5%'
            WHEN Discount_Percent <= 0.10
                THEN '6-10%'
            WHEN Discount_Percent <= 0.15
                THEN '11-15%'
            WHEN Discount_Percent <= 0.20
                THEN '16-20%'
            ELSE 'Above 20%'
        END AS Discount_Category,

        CASE
            WHEN Discount_Percent = 0 THEN 1
            WHEN Discount_Percent <= 0.05 THEN 2
            WHEN Discount_Percent <= 0.10 THEN 3
            WHEN Discount_Percent <= 0.15 THEN 4
            WHEN Discount_Percent <= 0.20 THEN 5
            ELSE 6
        END AS Sort_Order,

        COUNT(*) AS Total_Orders,

        SUM(Net_Sales) AS Total_Revenue,

        SUM(Profit) AS Total_Profit,

        SUM(Discount_Amount) AS Total_Discount,

        AVG(Net_Sales) AS Average_Order_Value

    FROM fact_sales

    WHERE Order_Status = 'Delivered'

    GROUP BY
        CASE
            WHEN Discount_Percent = 0
                THEN 'No Discount'
            WHEN Discount_Percent <= 0.05
                THEN '1-5%'
            WHEN Discount_Percent <= 0.10
                THEN '6-10%'
            WHEN Discount_Percent <= 0.15
                THEN '11-15%'
            WHEN Discount_Percent <= 0.20
                THEN '16-20%'
            ELSE 'Above 20%'
        END,

        CASE
            WHEN Discount_Percent = 0 THEN 1
            WHEN Discount_Percent <= 0.05 THEN 2
            WHEN Discount_Percent <= 0.10 THEN 3
            WHEN Discount_Percent <= 0.15 THEN 4
            WHEN Discount_Percent <= 0.20 THEN 5
            ELSE 6
        END
),

Discount_Performance AS (
    SELECT
        Discount_Category,
        Sort_Order,
        Total_Orders,
        Total_Revenue,
        Total_Profit,
        Total_Discount,
        Average_Order_Value,

        ROUND(
            Total_Profit * 100.0 /
            NULLIF(Total_Revenue, 0),
            2
        ) AS Profit_Margin_Percent,

        ROUND(
            Total_Revenue * 100.0 /
            NULLIF(SUM(Total_Revenue) OVER (), 0),
            2
        ) AS Revenue_Contribution_Percent

    FROM Discount_Analysis
)

SELECT
    Discount_Category,
    Total_Orders,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    ROUND(Total_Profit, 2) AS Total_Profit,
    ROUND(Total_Discount, 2) AS Total_Discount,
    ROUND(Average_Order_Value, 2) AS Average_Order_Value,
    Profit_Margin_Percent,
    Revenue_Contribution_Percent

FROM Discount_Performance

ORDER BY Sort_Order;
