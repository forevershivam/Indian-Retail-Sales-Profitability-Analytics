WITH Customer_Purchases AS (
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Customer_Segment,
        c.Region,
        COUNT(DISTINCT f.Order_ID) AS Total_Orders,
        ROUND(SUM(f.Net_Sales), 2) AS Total_Spending,
        ROUND(AVG(f.Net_Sales), 2) AS Average_Order_Value,
        MIN(f.Order_Date) AS First_Purchase,
        MAX(f.Order_Date) AS Last_Purchase
    FROM dim_customer c
    INNER JOIN fact_sales f
        ON c.Customer_ID = f.Customer_ID
    WHERE f.Order_Status = 'Delivered'
    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Customer_Segment,
        c.Region
),

Customer_Ranking AS (
    SELECT
        cp.Customer_ID,
        cp.Customer_Name,
        cp.Customer_Segment,
        cp.Region,
        cp.Total_Orders,
        cp.Total_Spending,
        cp.Average_Order_Value,
        cp.First_Purchase,
        cp.Last_Purchase,

        CASE
            WHEN cp.Total_Orders > 1 THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS Customer_Type,

        ROUND(
            cp.Total_Spending * 100.0 /
            NULLIF(SUM(cp.Total_Spending) OVER (), 0),
            3
        ) AS Revenue_Contribution_Percent,

        DENSE_RANK() OVER (
            ORDER BY cp.Total_Spending DESC
        ) AS Revenue_Rank

    FROM Customer_Purchases cp
)

SELECT
    cr.Customer_ID,
    cr.Customer_Name,
    cr.Customer_Segment,
    cr.Region,
    cr.Total_Orders,
    cr.Total_Spending,
    cr.Average_Order_Value,
    cr.First_Purchase,
    cr.Last_Purchase,
    cr.Customer_Type,
    cr.Revenue_Contribution_Percent,
    cr.Revenue_Rank
FROM Customer_Ranking cr
WHERE cr.Revenue_Rank <= 20
ORDER BY cr.Revenue_Rank, cr.Customer_ID;
