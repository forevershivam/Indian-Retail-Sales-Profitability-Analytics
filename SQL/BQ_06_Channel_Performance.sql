WITH Channel_Performance AS (
    SELECT
        Sales_Channel,

        COUNT(*) AS Total_Orders,

        SUM(
            CASE WHEN Order_Status = 'Delivered'
            THEN 1 ELSE 0 END
        ) AS Delivered_Orders,

        SUM(
            CASE WHEN Order_Status = 'Returned'
            THEN 1 ELSE 0 END
        ) AS Returned_Orders,

        SUM(
            CASE WHEN Order_Status = 'Cancelled'
            THEN 1 ELSE 0 END
        ) AS Cancelled_Orders,

        SUM(
            CASE WHEN Order_Status = 'Delivered'
            THEN Net_Sales ELSE 0 END
        ) AS Delivered_Revenue,

        SUM(
            CASE WHEN Order_Status = 'Delivered'
            THEN Profit ELSE 0 END
        ) AS Delivered_Profit

    FROM fact_sales

    GROUP BY Sales_Channel
),

Channel_Analysis AS (
    SELECT
        Sales_Channel,
        Total_Orders,
        Delivered_Orders,
        Returned_Orders,
        Cancelled_Orders,
        Delivered_Revenue,
        Delivered_Profit,

        ROUND(
            Returned_Orders * 100.0 /
            NULLIF(Total_Orders, 0), 2
        ) AS Return_Rate_Percent,

        ROUND(
            Cancelled_Orders * 100.0 /
            NULLIF(Total_Orders, 0), 2
        ) AS Cancellation_Rate_Percent,

        ROUND(
            Delivered_Profit * 100.0 /
            NULLIF(Delivered_Revenue, 0), 2
        ) AS Profit_Margin_Percent,

        ROUND(
            Delivered_Revenue * 100.0 /
            NULLIF(SUM(Delivered_Revenue) OVER (), 0),
            2
        ) AS Revenue_Contribution_Percent,

        DENSE_RANK() OVER (
            ORDER BY Delivered_Revenue DESC
        ) AS Revenue_Rank

    FROM Channel_Performance
)

SELECT
    Sales_Channel,
    Total_Orders,
    Delivered_Orders,
    Returned_Orders,
    Cancelled_Orders,

    ROUND(Delivered_Revenue, 2) AS Delivered_Revenue,
    ROUND(Delivered_Profit, 2) AS Delivered_Profit,

    Profit_Margin_Percent,
    Return_Rate_Percent,
    Cancellation_Rate_Percent,
    Revenue_Contribution_Percent,
    Revenue_Rank

FROM Channel_Analysis

ORDER BY Revenue_Rank, Sales_Channel;
