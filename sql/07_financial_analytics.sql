USE EnterpriseBI;
GO
/* Internet sales gross margin proxy: sales minus product cost. It is not GAAP operating profit. */
CREATE OR ALTER VIEW mart.vw_MonthlySales AS
WITH Monthly AS (
 SELECT d.CalendarYear,d.MonthNumber,d.YearMonth,r.RegionName,p.CategoryName,
  SUM(f.SalesAmount) Revenue,SUM(COALESCE(f.TotalProductCost,0)) ProductCost,
  SUM(f.SalesAmount-COALESCE(f.TotalProductCost,0)) GrossProfit,COUNT(DISTINCT f.SalesOrderNumber) Orders
 FROM mart.FactSalesInternet f JOIN mart.DimDate d ON d.DateKey=f.OrderDateKey
 LEFT JOIN mart.DimRegion r ON r.RegionKey=f.RegionKey JOIN mart.DimProduct p ON p.ProductKey=f.ProductKey
 GROUP BY d.CalendarYear,d.MonthNumber,d.YearMonth,r.RegionName,p.CategoryName)
SELECT *,GrossProfit/NULLIF(Revenue,0) MarginPct,
 LAG(Revenue) OVER(PARTITION BY RegionName,CategoryName ORDER BY CalendarYear,MonthNumber) PriorMonthRevenue,
 LAG(Revenue,12) OVER(PARTITION BY RegionName,CategoryName ORDER BY CalendarYear,MonthNumber) PriorYearRevenue,
 RANK() OVER(PARTITION BY CalendarYear,MonthNumber ORDER BY Revenue DESC) RegionalRank
FROM Monthly;
GO
