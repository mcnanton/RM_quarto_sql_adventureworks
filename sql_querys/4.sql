
--- QUERY 4 

--- Tabla donde cada fila es una combinacion de año-trimestre-descuento si/no.
--- col1 = año. col2= trimestre. col3 = descuento si / no. col4 = $$ vendido ese trimestre según descuento si/no

WITH r_sin_promocion AS
(
SELECT dd.CalendarYear, dd.CalendarQuarter, frs.SalesAmount, 'Sin Promocion' AS Promocion_SiNo
FROM (AdventureWorksDW2019.dbo.FactResellerSales frs INNER JOIN
AdventureWorksDW2019.dbo.DimDate dd ON frs.OrderDateKey = dd.DateKey)
INNER JOIN AdventureWorksDW2019.dbo.DimPromotion dp ON frs.PromotionKey = dp.PromotionKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013) AND 
dp.PromotionKey = 1

),

r_con_promocion AS 
(
SELECT dd.CalendarYear, dd.CalendarQuarter, frs.SalesAmount, 'Con Promocion' AS Promocion_SiNo
FROM (AdventureWorksDW2019.dbo.FactResellerSales frs INNER JOIN
AdventureWorksDW2019.dbo.DimDate dd ON frs.OrderDateKey = dd.DateKey)
INNER JOIN AdventureWorksDW2019.dbo.DimPromotion dp ON frs.PromotionKey = dp.PromotionKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013) AND 
dp.PromotionKey IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
),

i_sin_promocion AS
(
SELECT dd.CalendarYear, dd.CalendarQuarter, fis.SalesAmount, 'Sin Promocion' AS Promocion_SiNo
FROM (AdventureWorksDW2019.dbo.FactInternetSales fis  INNER JOIN
AdventureWorksDW2019.dbo.DimDate dd ON fis.OrderDateKey = dd.DateKey)
INNER JOIN AdventureWorksDW2019.dbo.DimPromotion dp ON fis.PromotionKey = dp.PromotionKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013) AND 
dp.PromotionKey = 1
),

i_con_promocion AS 
(
SELECT dd.CalendarYear, dd.CalendarQuarter, fis.SalesAmount, 'Con Promocion' AS Promocion_SiNo
FROM (AdventureWorksDW2019.dbo.FactInternetSales fis INNER JOIN
AdventureWorksDW2019.dbo.DimDate dd ON fis.OrderDateKey = dd.DateKey)
INNER JOIN AdventureWorksDW2019.dbo.DimPromotion dp ON fis.PromotionKey = dp.PromotionKey
WHERE dd.CalendarYear IN (2010, 2011, 2012, 2013) AND 
dp.PromotionKey IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
), 

todas AS 
(
SELECT CalendarYear, CalendarQuarter, SalesAmount, Promocion_SiNo
FROM r_sin_promocion
UNION ALL
SELECT CalendarYear, CalendarQuarter, SalesAmount, Promocion_SiNo
FROM r_con_promocion
UNION ALL
SELECT CalendarYear, CalendarQuarter, SalesAmount, Promocion_SiNo
FROM i_sin_promocion
UNION ALL
SELECT CalendarYear, CalendarQuarter, SalesAmount, Promocion_SiNo
FROM i_con_promocion
)

SELECT CalendarYear, CalendarQuarter, Promocion_SiNo, SUM(SalesAmount) AS SalesAmount
FROM todas
GROUP BY CalendarYear, CalendarQuarter, Promocion_SiNo
ORDER BY CalendarYear, CalendarQuarter

