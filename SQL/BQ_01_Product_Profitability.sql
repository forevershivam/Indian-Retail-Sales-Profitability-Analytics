WITH Product_Performance AS (
    SELECT
        p.Product_Name,
        p.Category,
        p.Brand,

        ROUND(SUM(f.Net_Sales), 2) AS Total_Sales,

        ROUND(SUM(f.Profit), 2) AS Total_Profit

    FROM fact_sales f

    INNER JOIN dim_product p
        ON f.Product_ID = p.Product_ID

    WHERE f.Order_Status = 'Delivered'

    GROUP BY
        f.Product_ID,
        p.Product_Name,
        p.Category,
        p.Brand
),

Product_Ranking AS (
    SELECT
        *,
        ROUND(
            Total_Profit * 100.0 /
            NULLIF(Total_Sales, 0), 2
        ) AS Profit_Margin_Percent,

        ROUND(
            Total_Sales * 100.0 /
            NULLIF(SUM(Total_Sales) OVER (), 0), 2
        ) AS Sales_Contribution_Percent,

        DENSE_RANK() OVER (
            ORDER BY Total_Profit DESC
        ) AS Profit_Rank

    FROM Product_Performance
)

SELECT *
FROM Product_Ranking
WHERE Profit_Rank <= 10
ORDER BY Profit_Rank, Product_Name;
