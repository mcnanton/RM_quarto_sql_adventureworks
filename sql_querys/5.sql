WITH helper1 AS (SELECT DISTINCT isales.SalesOrderNumber, categ.SpanishProductCategoryName,
CASE WHEN isales.PromotionKey = '1' THEN 'sin_promocion'
ELSE 'con_promocion'
END AS 'con_sin_promo'
FROM dbo.FactInternetSales isales
LEFT JOIN dbo.DimProduct prod ON isales.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
WHERE YEAR(isales.OrderDate) IN (2010, 2011, 2012, 2013)),

helper2 AS (
SELECT SpanishProductCategoryName, con_sin_promo, COUNT(*) as total
FROM helper1
GROUP BY SpanishProductCategoryName, con_sin_promo),

helper3 AS(
SELECT SpanishProductCategoryName,
SUM(CASE WHEN con_sin_promo = 'con_promocion' THEN total END) AS productos_con_promocion,
SUM(CASE WHEN con_sin_promo = 'sin_promocion' THEN total END) AS productos_sin_promocion,
SUM(total) AS total_categoria
FROM helper2
GROUP BY SpanishProductCategoryName)

SELECT SpanishProductCategoryName, total_categoria, productos_con_promocion, productos_sin_promocion, FORMAT((productos_con_promocion * 1.0 /total_categoria), 'P') as porc_con_promocion, FORMAT((productos_sin_promocion * 1.0 /total_categoria), 'P') as porc_sin_promocion
FROM helper3
