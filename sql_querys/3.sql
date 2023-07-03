WITH reseller AS
(
SELECT frs.ProductKey, prod.EnglishProductName as Product, frs.OrderQuantity, frs.UnitPrice, categ.SpanishProductCategoryName as Categoria, 'Reseller Sales' AS CanalVenta, UnitPrice*OrderQuantity AS MontoVendido
FROM dbo.FactResellerSales frs
LEFT JOIN dbo.DimProduct prod ON frs.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
),

internet AS 
(
SELECT fis.ProductKey, prod.EnglishProductName  as Product, fis.OrderQuantity, fis.UnitPrice, categ.SpanishProductCategoryName as Categoria, 'Internet Sales' AS CanalVenta, UnitPrice*OrderQuantity AS MontoVendido
FROM dbo.FactInternetSales fis
LEFT JOIN dbo.DimProduct prod ON fis.ProductKey = prod.ProductKey
LEFT JOIN dbo.DimProductSubcategory sub ON prod.ProductSubcategoryKey = sub.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON sub.ProductCategoryKey = categ.ProductCategoryKey
),

ambas AS 
(
SELECT Categoria,  Product, OrderQuantity, UnitPrice, CanalVenta, MontoVendido
FROM reseller
UNION ALL
SELECT Categoria, Product, OrderQuantity, UnitPrice, CanalVenta, MontoVendido
FROM internet
),

tabla_sumario AS(
SELECT *,
SUM(OrderQuantity) OVER(PARTITION BY Categoria, CanalVenta) AS n_vend_categ,
SUM(OrderQuantity) OVER(PARTITION BY Categoria, CanalVenta, Product) AS n_vend_prod_categ,
SUM(MontoVendido) OVER(PARTITION BY Categoria, CanalVenta) AS vtas_categ,
SUM(MontoVendido) OVER(PARTITION BY Categoria, CanalVenta, Product) AS vtas_prod_categ
FROM ambas),

tabla_sumario_producto AS (
SELECT DISTINCT CanalVenta, Categoria, Product, n_vend_categ, n_vend_prod_categ, vtas_categ, vtas_prod_categ
FROM tabla_sumario),

rn_tabla_sumario_producto AS(
SELECT *, (vtas_prod_categ*100/vtas_categ) AS porc_ingr_categoria,
ROW_NUMBER() OVER(PARTITION BY Categoria, CanalVenta ORDER BY vtas_prod_categ DESC) AS ranking_cantidad_pvendidos_categoria
FROM tabla_sumario_producto
) 
SELECT *
FROM rn_tabla_sumario_producto
WHERE ranking_cantidad_pvendidos_categoria < 4
-- Uso intencional del row number en vez de dense_rank dado que en el canal internet sales muchos productos fueron vendidos solo 1 vez y todos cumplen el where de la línea anterior