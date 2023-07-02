WITH producto_venta_reseller AS (SELECT rsales.ProductKey, rsales.OrderQuantity, rsales.SalesOrderNumber, dr.ResellerName, rsales.PromotionKey
FROM dbo.FactResellerSales rsales
LEFT JOIN dbo.DimReseller dr ON rsales.ResellerKey = dr.ResellerKey
WHERE YEAR(rsales.OrderDate) IN (2010, 2011, 2012, 2013)),
sod_reseller AS(
    SELECT DISTINCT SalesOrderNumber, ResellerName
    FROM producto_venta_reseller
),
total_vtas_reseller AS(
    SELECT ResellerName, COUNT(*) as total_ventas
    FROM producto_venta_reseller
    GROUP BY ResellerName
),
total_items_reseller AS (
    SELECT ResellerName, SUM(OrderQuantity) as total_productos
    FROM producto_venta_reseller
    GROUP BY ResellerName
)
SELECT tvr.ResellerName, total_ventas, tir.total_productos
FROM total_vtas_reseller tvr
LEFT JOIN total_items_reseller tir ON tvr.ResellerName = tir.ResellerName