WITH tabla1 AS (SELECT isales.PromotionKey, COUNT(*) as total_uso_id_promo
FROM dbo.FactInternetSales isales
LEFT JOIN dbo.DimProduct prod ON isales.ProductKey = prod.ProductKey
WHERE isales.PromotionKey != '1'
AND YEAR(isales.OrderDate) IN (2010, 2011, 2012, 2013)
GROUP BY isales.PromotionKey)
SELECT t1.PromotionKey Clave , t1.total_uso_id_promo AS n_veces_uso, promo.SpanishPromotionName, promo.SpanishPromotionType Tipo, promo.SpanishPromotionCategory Categoria
FROM tabla1 t1
LEFT JOIN dbo.DimPromotion promo on t1.PromotionKey = promo.PromotionKey
ORDER BY total_uso_id_promo DESC