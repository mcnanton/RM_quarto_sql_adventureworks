WITH reseller AS
(
SELECT frs.ProductKey, prod.SpanishProductName, frs.OrderQuantity, frs.UnitPrice, categ.SpanishProductCategoryName, 'Reseller Sales' AS CanalVenta, UnitPrice*OrderQuantity AS MontoVendido
FROM dbo.FactResellerSales frs
LEFT JOIN dbo.DimProduct prod ON frs.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
),

internet AS 
(
SELECT fis.ProductKey, prod.SpanishProductName, fis.OrderQuantity, fis.UnitPrice, categ.SpanishProductCategoryName, 'Internet Sales' AS CanalVenta, UnitPrice*OrderQuantity AS MontoVendido
FROM dbo.FactInternetSales fis
LEFT JOIN dbo.DimProduct prod ON fis.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
),

ambas AS 
(
SELECT ProductKey, SpanishProductCategoryName, SpanishProductName, OrderQuantity, UnitPrice, CanalVenta, MontoVendido
FROM reseller
UNION ALL
SELECT ProductKey, SpanishProductCategoryName, SpanishProductName, OrderQuantity, UnitPrice, CanalVenta, MontoVendido
FROM internet
),

tabla_sumario AS(
SELECT *,
SUM(OrderQuantity) OVER(PARTITION BY SpanishProductCategoryName, CanalVenta) AS n_prod_vendidos_categoria_canal,
SUM(OrderQuantity) OVER(PARTITION BY SpanishProductCategoryName, CanalVenta, ProductKey) AS ventas_producto_categoria_canal,
SUM(MontoVendido) OVER(PARTITION BY SpanishProductCategoryName, CanalVenta) AS monto_vendido_categoria_canal,
SUM(MontoVendido) OVER(PARTITION BY SpanishProductCategoryName, CanalVenta, ProductKey) AS monto_vendido_producto_categoria_canal
FROM ambas),

tabla_sumario_producto AS (
SELECT DISTINCT CanalVenta, SpanishProductCategoryName, ProductKey, SpanishProductName, n_prod_vendidos_categoria_canal, ventas_producto_categoria_canal, monto_vendido_categoria_canal, monto_vendido_producto_categoria_canal
FROM tabla_sumario),

rn_tabla_sumario_producto AS(
SELECT *, (monto_vendido_producto_categoria_canal*100/monto_vendido_categoria_canal) AS porc_monetario_categoria,
ROW_NUMBER() OVER(PARTITION BY SpanishProductCategoryName, CanalVenta ORDER BY ventas_producto_categoria_canal DESC) AS ranking_cantidad_pvendidos_categoria
FROM tabla_sumario_producto
) 
SELECT *
FROM rn_tabla_sumario_producto
WHERE ranking_cantidad_pvendidos_categoria < 3
-- Uso intencional del row number en vez de dense_rank dado que en el canal internet sales muchos productos fueron vendidos solo 1 vez y todos cumplen el where de la línea anterior