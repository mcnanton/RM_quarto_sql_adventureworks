SELECT SpanishPromotionName, SpanishPromotionType, SpanishPromotionCategory
FROM dbo.DimPromotion
WHERE PromotionKey IN (SELECT isales.PromotionKey
FROM dbo.FactInternetSales isales
LEFT JOIN dbo.DimProduct prod ON isales.ProductKey = prod.ProductKey
WHERE isales.PromotionKey != '1'
AND YEAR(isales.OrderDate) IN (2010, 2011, 2012, 2013))