
--- QUERY 2A 

--- 2010-2013: SUBCATEGORIAS de productos más vendidas en TOTAL AMBOS CANALES DE VENTAS

WITH reseller AS
(
SELECT dp.ProductSubcategoryKey, dps.SpanishProductSubcategoryName, frs.OrderQuantity, 'Reseller Sales' AS CanalVenta  
FROM ((AdventureWorksDW2019.dbo.FactResellerSales frs INNER JOIN
AdventureWorksDW2019.dbo.DimProduct dp ON frs.ProductKey = dp.ProductKey) 
INNER JOIN AdventureWorksDW2019.dbo.DimProductSubcategory dps 
ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey) INNER JOIN 
AdventureWorksDW2019.dbo.DimDate dd ON frs.OrderDateKey = dd.DateKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013)
),

internet AS 
(
SELECT dp.ProductSubcategoryKey, dps.SpanishProductSubcategoryName, fis.OrderQuantity, 'Internet Sales' AS CanalVenta
FROM ((AdventureWorksDW2019.dbo.FactInternetSales fis INNER JOIN
AdventureWorksDW2019.dbo.DimProduct dp ON fis.ProductKey = dp.ProductKey) 
INNER JOIN AdventureWorksDW2019.dbo.DimProductSubcategory dps 
ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey) INNER JOIN 
AdventureWorksDW2019.dbo.DimDate dd ON fis.OrderDateKey = dd.DateKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013)
),

ambas AS 
(
SELECT ProductSubcategoryKey, SpanishProductSubcategoryName, OrderQuantity, CanalVenta
FROM reseller
UNION 
SELECT ProductSubcategoryKey, SpanishProductSubcategoryName, OrderQuantity, CanalVenta
FROM internet
),

ambas_agrupadas AS
(
SELECT ProductSubcategoryKey, SpanishProductSubcategoryName, CanalVenta, SUM(OrderQuantity) AS ProductosVendidos_PorCanalVenta
FROM ambas
GROUP BY ProductSubcategoryKey, SpanishProductSubcategoryName, CanalVenta
)

SELECT SpanishProductSubcategoryName, CanalVenta, ProductosVendidos_PorCanalVenta,
SUM(ProductosVendidos_PorCanalVenta) OVER(PARTITION BY SpanishProductSubcategoryName) AS ProductosVendidos_PorCategoria
FROM ambas_agrupadas
ORDER BY ProductosVendidos_Porcategoria DESC

