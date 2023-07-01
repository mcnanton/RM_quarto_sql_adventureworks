WITH tabla_granular_producto AS 
(SELECT p.SpanishProductName, categ.SpanishProductCategoryName, 
CASE WHEN rsales.EmployeeKey IS NULL THEN 'Internet'
ELSE 'Reseller'
END AS 'canal_venta',
COALESCE (rsales.OrderQuantity, isales.OrderQuantity) as cantidad,
COALESCE (rsales.UnitPrice, isales.UnitPrice) as precio
FROM dbo.DimProduct p
LEFT JOIN dbo.DimProductSubcategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory categ ON s.ProductCategoryKey = categ.ProductCategoryKey
LEFT JOIN dbo.FactResellerSales rsales ON p.ProductKey = rsales.ProductKey 
LEFT JOIN dbo.FactInternetSales isales on p.ProductKey = isales.ProductKey
WHERE YEAR(isales.OrderDate) IN (2010, 2011, 2012, 2013)),
tabla_producto_categoria AS(
SELECT gr.SpanishProductName, gr.SpanishProductCategoryName, gr.canal_venta, gr.precio, SUM(gr.cantidad) AS total_cantidad, gr.precio * SUM(gr.cantidad) AS importe_producto
FROM tabla_granular_producto gr
GROUP BY gr.SpanishProductName, gr.SpanishProductCategoryName, gr.canal_venta, gr.precio),
tabla_sumario AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY SpanishProductCategoryName ORDER BY total_cantidad DESC) AS ranking_cantidad_pvendidos_categoria,
SUM(importe_producto) OVER(PARTITION BY SpanishProductCategoryName) AS total_importe_para_categoria,
SUM(importe_producto) OVER() AS total_importe_categoria
FROM tabla_producto_categoria)
SELECT SpanishProductName, SpanishProductCategoryName, ranking_cantidad_pvendidos_categoria, 
importe_producto*100/total_importe_para_categoria as porc_importe_producto_categoria
FROM tabla_sumario
WHERE ranking_cantidad_pvendidos_categoria < 11