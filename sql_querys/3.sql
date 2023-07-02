WITH reseller AS
(
SELECT frs.ProductKey, prod.SpanishProductName, frs.OrderQuantity, frs.UnitPrice, categ.SpanishProductCategoryName, 'Reseller Sales' AS CanalVenta
FROM dbo.FactResellerSales frs
LEFT JOIN dbo.DimProduct prod ON frs.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
),

internet AS 
(
SELECT fis.ProductKey, prod.SpanishProductName, fis.OrderQuantity, fis.UnitPrice, categ.SpanishProductCategoryName, 'Internet Sales' AS CanalVenta
FROM dbo.FactInternetSales fis
LEFT JOIN dbo.DimProduct prod ON fis.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
),

ambas AS 
(
SELECT ProductKey, SpanishProductCategoryName, SpanishProductName, OrderQuantity, UnitPrice, CanalVenta
FROM reseller
UNION 
SELECT ProductKey, SpanishProductCategoryName, SpanishProductName, OrderQuantity, UnitPrice, CanalVenta
FROM internet
),

tabla_sumario AS(
SELECT *,
SUM(OrderQuantity) OVER(PARTITION BY SpanishProductCategoryName, CanalVenta) AS n_prod_vendidos_categoria_canal,
SUM(OrderQuantity) OVER(PARTITION BY SpanishProductCategoryName, CanalVenta, ProductKey) AS ventas_producto_categoria_canal
FROM ambas),

tabla_sumario_producto AS (
SELECT DISTINCT CanalVenta, SpanishProductCategoryName, ProductKey, SpanishProductName, n_prod_vendidos_categoria_canal, ventas_producto_categoria_canal,
RANK() OVER(PARTITION BY SpanishProductCategoryName, CanalVenta ORDER BY ventas_producto_categoria_canal DESC) AS ranking_cantidad_pvendidos_categoria
FROM tabla_sumario)
SELECT *
FROM tabla_sumario_producto
WHERE ranking_cantidad_pvendidos_categoria< 5