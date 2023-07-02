WITH producto_venta_reseller AS (SELECT rsales.ProductKey, rsales.SalesOrderNumber, dr.ResellerName, rsales.PromotionKey
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
ventas_con_promo AS (
    SELECT DISTINCT ResellerName, SalesOrderNumber
    FROM producto_venta_reseller
    WHERE PromotionKey != '1'
),
total_vtas_reseller_promo AS (
    SELECT ResellerName, COUNT(*) as total_ventas_promo
    FROM ventas_con_promo
    GROUP BY ResellerName
), totales AS (
SELECT tvr.ResellerName, tvr.total_ventas, ISNULL(tvrp.total_ventas_promo, 0) as total_ventas_promo
FROM total_vtas_reseller tvr
LEFT JOIN total_vtas_reseller_promo tvrp ON tvr.ResellerName = tvrp.ResellerName)
SELECT ResellerName, total_ventas, total_ventas_promo, (total_ventas_promo*100/total_ventas) as porc_vtas_con_promo
FROM totales
ORDER BY porc_vtas_con_promo DESC