SELECT DISTINCT isales.PromotionKey, COUNT(*) as total_uso_id_promo
FROM dbo.FactInternetSales isales
LEFT JOIN dbo.DimProduct prod ON isales.ProductKey = prod.ProductKey
WHERE isales.PromotionKey != '1'
AND isales.SalesOrderNumber IN (SELECT sales.SalesOrderNumber FROM dbo.FactInternetSales sales WHERE YEAR(sales.OrderDate) IN (2010, 2011, 2012, 2013))
GROUP BY isales.PromotionKey