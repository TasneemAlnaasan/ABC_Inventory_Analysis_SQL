

-- ABC Inventory Analysis
-- Calculating Annual Sales Quantity
select  SKUID, round(SUM( OrderQuantity),2) as Annual_Sale_Quantity
from Inventory1..PastOrders  
where OrderDate  Between '2019-01-30 00:00:00.000' AND '2020-01-30 00:00:00.000'
group by SKUID 

--SKUID	  Annual_Sale_Quantity
--1497CA	49022.2
--2212AA	1040
--2646AA	4504
--2326CA	36085.32
--3551CA	139150
--1317BA	996.95
--1265CA	 30
----------------------------------------------------------------------------
--Calculating Revenue 
with AnnualSaleQuantity as( select  SKUID, round(SUM( OrderQuantity),2) as Annual_Sale_Quantity
                           from Inventory1..PastOrders  
						   where OrderDate  Between '2019-01-30 00:00:00.000' AND '2020-01-30 00:00:00.000'
						   group by SKUID) 
                 SELECT ROW_NUMBER() OVER(ORDER BY ROUND(SUM(s.UnitPrice*A.Annual_Sale_Quantity),2) DESC) AS SKUID_Rank_by_Revenue,
                         s.SKUID, ROUND(SUM(s.UnitPrice*A.Annual_Sale_Quantity),2) AS 'Annual_Revenue'
                         FROM Inventory1..Stock s
                          JOIN AnnualSaleQuantity A
                         ON s.SKUID = A.SKUID
                         GROUP BY s.SKUID
--SKUID_Rank_by_Revenue	SKUID	Annual_Revenue
--1	                    1244AA	34450066.2
--2	                    1295CA	27954500
--3	                    1193BA	26833060
--4	                    1116CA	22366516.8
--5	                    1281BA	21981015

-----------------------------------------------------------------------------------
--Calculating Cummulative Revenue, Total Revenue, Cummulative Percentage of Revenue and Cummulative Percentage of Inventory 
with AnnualSaleQuantity as( select  SKUID, round(SUM( OrderQuantity),2) as Annual_Sale_Quantity
                           from Inventory1..PastOrders  
						   where OrderDate  Between '2019-01-30 00:00:00.000' AND '2020-01-30 00:00:00.000'
						   group by SKUID),
                 t1  as (SELECT ROW_NUMBER() OVER(ORDER BY ROUND(SUM(s.UnitPrice*A.Annual_Sale_Quantity),2) DESC) AS SKUID_Rank_by_Revenue,
                         s.SKUID, ROUND(SUM(s.UnitPrice*A.Annual_Sale_Quantity),2) AS 'Annual_Revenue'
                         FROM Inventory1..Stock s
                          JOIN AnnualSaleQuantity A
                         ON s.SKUID = A.SKUID
                         GROUP BY s.SKUID),  
                 t2 as (Select SKUID_Rank_by_Revenue, SKUID, Annual_Revenue
                        From t1)   
 SELECT SKUID_Rank_by_Revenue, SKUID, Annual_Revenue,
                             SUM(Annual_Revenue) OVER(ORDER BY Annual_Revenue DESC) AS Cumulative_Revenue,
                              SUM(Annual_Revenue) OVER() AS Total_Revenue,
                            ROUND(100*SUM(Annual_Revenue) OVER(ORDER BY Annual_Revenue DESC)/SUM(Annual_Revenue) OVER(),2) AS Cumulative_Percentage_of_Revenue,
                           Cast (100*1.0*SKUID_Rank_by_Revenue/(SELECT COUNT(*) FROM t2) as decimal (10, 0)) AS Cumulative_Percentage_of_Inventory
From t2

--SKUID_Rank_by_Revenue	SKUID	Annual_Revenue	Cumulative_Revenue	Total_Revenue	Cumulative_Percentage_of_Revenue	Cumulative_Percentage_of_Inventory	
--1	                    1244AA	34450066.2	     34450066.2	        689213963.78	         5	                                0	                           
--2	                    1295CA	27954500	     62404566.2	        689213963.78	         9.05	                            1	                           
--3	                    1193BA	26833060	     89237626.2	        689213963.78	        12.95	                            1	                           
--4	                    1116CA	22366516.8	     111604143	        689213963.78	        16.19	                            1	                           
--5	                    1281BA	21981015	     133585158	        689213963.78	        19.38	                            2	                           
--6	                    1126CA	19597344	     153182502	        689213963.78	        22.23	                            2	                           
--7	                    2117BA	17093805.6	     170276307.6	    689213963.78	        24.71	                            2	                           
--8	                    1077CA	16571241.51	     186847549.11	    689213963.78	        27.11	                            3	                           
--9	                    1964BA	16217488.34	     203065037.45	    689213963.78	        29.46	                            3	                           
--10	                1083AA	15765985.6	     218831023.05	    689213963.78	        31.75	                            3	                           

---------------------------------------------------------------------------------------------
--Specifying the segment of each SKUID
with AnnualSaleQuantity as( select  SKUID, round(SUM( OrderQuantity),2) as Annual_Sale_Quantity
                           from Inventory1..PastOrders  
						   where OrderDate  Between '2019-01-30 00:00:00.000' AND '2020-01-30 00:00:00.000'
						   group by SKUID ),
                 t1  as (SELECT ROW_NUMBER() OVER(ORDER BY ROUND(SUM(s.UnitPrice*A.Annual_Sale_Quantity),2) DESC) AS SKUID_Rank_by_Revenue,
                         s.SKUID, ROUND(SUM(s.UnitPrice*A.Annual_Sale_Quantity),2) AS 'Annual_Revenue'
                         FROM Inventory1..Stock s
                         JOIN AnnualSaleQuantity A
                         ON s.SKUID = A.SKUID
                         GROUP BY s.SKUID),  
                 t2 as (Select SKUID_Rank_by_Revenue, SKUID, Annual_Revenue
                        From t1),   
                ABC_Analysis AS (SELECT SKUID_Rank_by_Revenue, SKUID, Annual_Revenue,
                             SUM(Annual_Revenue) OVER(ORDER BY Annual_Revenue DESC) AS Cumulative_Revenue,
                              SUM(Annual_Revenue) OVER() AS Total_Revenue,
                            ROUND(100*SUM(Annual_Revenue) OVER(ORDER BY Annual_Revenue DESC)/SUM(Annual_Revenue) OVER(),2) AS Cumulative_Percentage_of_Revenue,
                           Cast (100*1.0*SKUID_Rank_by_Revenue/(SELECT COUNT(*) FROM t2) as decimal (10, 0)) AS Cumulative_Percentage_of_Inventory
                      From t2)
SELECT 
SKUID_Rank_by_Revenue, SKUID, Annual_Revenue, 
Cumulative_Revenue, Total_Revenue, Cumulative_Percentage_of_Revenue, Cumulative_Percentage_of_Inventory,
Case When Cumulative_Percentage_of_Revenue <= '40' Then 'A'
      When Cumulative_Percentage_of_Revenue <= '70' Then 'B' else 'C'  End  AS ABC_Segment
FROM ABC_Analysis;

--SKUID_Rank_by_Revenue	SKUID	Annual_Revenue	Cumulative_Revenue	Total_Revenue	Cumulative_Percentage_of_Revenue	Cumulative_Percentage_of_Inventory	ABC_Segment
--1	                    1244AA	34450066.2	     34450066.2	        689213963.78	         5	                                0	                           A
--2	                    1295CA	27954500	     62404566.2	        689213963.78	         9.05	                            1	                           A
--3	                    1193BA	26833060	     89237626.2	        689213963.78	        12.95	                            1	                           A
--4	                    1116CA	22366516.8	     111604143	        689213963.78	        16.19	                            1	                           A
--5	                    1281BA	21981015	     133585158	        689213963.78	        19.38	                            2	                           A
--6	                    1126CA	19597344	     153182502	        689213963.78	        22.23	                            2	                           A
--7	                    2117BA	17093805.6	     170276307.6	    689213963.78	        24.71	                            2	                           A
--8	                    1077CA	16571241.51	     186847549.11	    689213963.78	        27.11	                            3	                           A
--9	                    1964BA	16217488.34	     203065037.45	    689213963.78	        29.46	                            3	                           A
--10	                1083AA	15765985.6	     218831023.05	    689213963.78	        31.75	                            3	                           A






