WITH orden_reseller_anio AS (
    SELECT DISTINCT rsales.SalesOrderNumber, dr.ResellerName, YEAR(rsales.OrderDate) AS anio
    FROM dbo.FactResellerSales rsales
    LEFT JOIN dbo.DimReseller dr ON rsales.ResellerKey = dr.ResellerKey
    WHERE YEAR(rsales.OrderDate) IN (2010, 2011, 2012, 2013)
),
top_resellers AS (
    SELECT TOP 5 ResellerName, COUNT(*) AS total_ventas
    FROM dbo.FactResellerSales rsales
    LEFT JOIN dbo.DimReseller dr ON rsales.ResellerKey = dr.ResellerKey
    WHERE YEAR(rsales.OrderDate) IN (2010, 2011, 2012, 2013)
    GROUP BY ResellerName
    ORDER BY COUNT(*) DESC
)
SELECT ora.ResellerName, anio, COUNT(*) AS total_ventas_reseller_anio
FROM orden_reseller_anio ora
JOIN top_resellers ON ora.ResellerName = top_resellers.ResellerName
GROUP BY ora.ResellerName, anio