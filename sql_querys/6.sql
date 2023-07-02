SELECT isales.PromotionKey, COUNT(*) as total_uso_id_promo
FROM dbo.FactInternetSales isales
LEFT JOIN dbo.DimProduct prod ON isales.ProductKey = prod.ProductKey
WHERE isales.PromotionKey != '1'
AND YEAR(isales.OrderDate) IN (2010, 2011, 2012, 2013)
GROUP BY isales.PromotionKey
ORDER BY total_uso_id_promo DESC