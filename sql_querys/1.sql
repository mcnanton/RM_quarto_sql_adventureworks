
--- QUERY 1 

--- Tabla donde cada fila es una combinacion de año-trimestre-canal de ventas.
--- col1 = año. col2= trimestre. col3 = canal de ventas. col4 = $$ vendido ese trimestre.

WITH reseller AS
(
SELECT dd.CalendarYear, dd.CalendarQuarter, frs.SalesAmount, 'Reseller Sales' AS CanalVenta
FROM AdventureWorksDW2019.dbo.FactResellerSales frs INNER JOIN
AdventureWorksDW2019.dbo.DimDate dd ON frs.OrderDateKey = dd.DateKey
),

internet AS 
(
SELECT dd.CalendarYear, dd.CalendarQuarter, fis.SalesAmount, 'Internet Sales' AS CanalVenta
FROM AdventureWorksDW2019.dbo.FactInternetSales fis  INNER JOIN
AdventureWorksDW2019.dbo.DimDate dd ON fis.OrderDateKey = dd.DateKey
),

ambas AS 
(
SELECT CalendarYear, CalendarQuarter, SalesAmount, CanalVenta
FROM reseller
UNION 
SELECT CalendarYear, CalendarQuarter, SalesAmount, CanalVenta
FROM internet
)

SELECT CalendarYear, CalendarQuarter, CanalVenta, SUM(SalesAmount) AS SalesAmount
FROM ambas
GROUP BY CalendarYear, CalendarQuarter, CanalVenta
ORDER BY CalendarYear, CalendarQuarter

