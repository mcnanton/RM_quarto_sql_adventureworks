--- QUERY 2B 

--- 2010-2013: CATEGORIAS de productos más vendidas en TOTAL AMBOS CANALES DE VENTAS

WITH reseller AS
(
SELECT dpc.ProductCategoryKey, dpc.SpanishProductCategoryName, frs.OrderQuantity, 'Reseller Sales' AS CanalVenta  
FROM (((AdventureWorksDW2019.dbo.FactResellerSales frs INNER JOIN
AdventureWorksDW2019.dbo.DimProduct dp ON frs.ProductKey = dp.ProductKey) 
INNER JOIN AdventureWorksDW2019.dbo.DimProductSubcategory dps 
ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey) INNER JOIN 
AdventureWorksDW2019.dbo.DimProductCategory dpc ON dps.ProductCategoryKey = dpc.ProductCategoryKey)
INNER JOIN 
AdventureWorksDW2019.dbo.DimDate dd ON frs.OrderDateKey = dd.DateKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013)
),

internet AS 
(
SELECT dpc.ProductCategoryKey, dpc.SpanishProductCategoryName, fis.OrderQuantity, 'Internet Sales' AS CanalVenta  
FROM (((AdventureWorksDW2019.dbo.FactInternetSales fis INNER JOIN
AdventureWorksDW2019.dbo.DimProduct dp ON fis.ProductKey = dp.ProductKey) 
INNER JOIN AdventureWorksDW2019.dbo.DimProductSubcategory dps 
ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey) INNER JOIN 
AdventureWorksDW2019.dbo.DimProductCategory dpc ON dps.ProductCategoryKey = dpc.ProductCategoryKey)
INNER JOIN 
AdventureWorksDW2019.dbo.DimDate dd ON fis.OrderDateKey = dd.DateKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013)
),

ambas AS 
(
SELECT ProductCategoryKey, SpanishProductCategoryName, OrderQuantity, CanalVenta
FROM reseller
UNION ALL
SELECT ProductCategoryKey, SpanishProductCategoryName, OrderQuantity, CanalVenta
FROM internet
),

ambas_agrupadas AS
(
SELECT ProductCategoryKey, SpanishProductCategoryName, CanalVenta, SUM(OrderQuantity) AS ProductosVendidos_PorCanalVenta
FROM ambas
GROUP BY ProductCategoryKey, SpanishProductCategoryName, CanalVenta
)

SELECT SpanishProductCategoryName, CanalVenta, ProductosVendidos_PorCanalVenta,
SUM(ProductosVendidos_PorCanalVenta) OVER(PARTITION BY SpanishProductCategoryName) AS ProductosVendidos_PorCategoria
FROM ambas_agrupadas
ORDER BY ProductosVendidos_PorCategoria DESC

