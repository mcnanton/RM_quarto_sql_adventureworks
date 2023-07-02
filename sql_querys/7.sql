WITH orderid_reseller AS (SELECT DISTINCT rsales.SalesOrderNumber, dr.ResellerName
FROM dbo.FactResellerSales rsales
LEFT JOIN dbo.DimReseller dr ON rsales.ResellerKey = dr.ResellerKey
WHERE YEAR(rsales.OrderDate) IN (2010, 2011, 2012, 2013))

SELECT TOP 5 ResellerName, COUNT(*) as total_ventas
FROM orderid_reseller
GROUP BY ResellerName
ORDER BY total_ventas DESC