WITH
## Calculate and rank the recency
recently AS (
    SELECT *
      ,CASE WHEN prc_rn_r BETWEEN 0 AND 0.2 THEN 5
            WHEN prc_rn_r > 0.2 AND prc_rn_r <=0.4 THEN 4
            WHEN prc_rn_r > 0.4 AND prc_rn_r <=0.6 THEN 3
            WHEN prc_rn_r > 0.6 AND prc_rn_r <=0.8 THEN 2
            ELSE 1
      END Score_r
FROM (
    SELECT *
        ,PERCENT_RANK() OVER(ORDER BY Recently_order DESC) AS prc_rn_r
    FROM (
        SELECT  CustomerID, MAX(OrderDate) AS Recently_order
        FROM `adventureworks2019.Sales.SalesOrderHeader`
        GROUP BY CustomerID)))
    
## Calculate and rank the frequency
,frequency AS (
    SELECT *,
      CASE WHEN prc_rn_f BETWEEN 0 AND 0.2 THEN 5
                  WHEN prc_rn_f > 0.2 AND prc_rn_f <=0.4 THEN 4
                  WHEN prc_rn_f > 0.4 AND prc_rn_f <=0.6 THEN 3
                  WHEN prc_rn_f > 0.6 AND prc_rn_f <=0.8 THEN 2
                  ELSE 1
        END Score_f
FROM (
    SELECT *
              ,PERCENT_RANK() OVER(ORDER BY total_order DESC) AS prc_rn_f
      FROM (
            SELECT CustomerID, COUNT( DISTINCT SalesOrderID) AS total_order
            FROM `adventureworks2019.Sales.SalesOrderHeader`
            GROUP BY CustomerID)))

## Calculate and rank the moneytary
,moneytary AS (
    SELECT *,
      CASE WHEN prc_rn_m BETWEEN 0 AND 0.2 THEN 5
                  WHEN prc_rn_m > 0.2 AND prc_rn_m <=0.4 THEN 4
                  WHEN prc_rn_m > 0.4 AND prc_rn_m <=0.6 THEN 3
                  WHEN prc_rn_m > 0.6 AND prc_rn_m <=0.8 THEN 2
                  ELSE 1
        END Score_m
FROM (
    SELECT *
          ,PERCENT_RANK() OVER(ORDER BY Monetary DESC) AS prc_rn_m
    FROM (
        SELECT CustomerID, MAX(TotalDue) AS Monetary
        FROM `adventureworks2019.Sales.SalesOrderHeader`
        GROUP BY CustomerID)))

## Megre each point to a string point     
SELECT *
        ,CASE WHEN Segment_code IN (555, 554, 544, 545, 454, 455, 445) THEN "Champions"
                WHEN Segment_code IN (543, 444, 435, 355, 354, 345, 344, 335) THEN "Loyal Customers"
                WHEN Segment_code IN (553, 551, 552, 541, 542, 533, 532, 531, 452, 451, 442, 441, 431, 453, 433, 432, 423, 353, 352, 351, 342, 341, 333, 323) THEN "Potential Loyalist"
                WHEN Segment_code IN (512, 511, 422, 421, 412, 411, 311) THEN "Recent Customers"
                WHEN Segment_code IN (525, 524, 523, 522, 521, 515, 514, 513, 425, 424, 413, 414, 415,315, 314, 313) THEN "Promising"
                WHEN Segment_code IN (535, 534, 443, 434, 343, 334, 325, 324) THEN "Customers Needing Attention"
                WHEN Segment_code IN (331, 321, 312, 221, 213) THEN "About To Sleep"
                WHEN Segment_code IN (255, 254, 245, 244, 253, 252, 243, 242, 235, 234, 225, 224, 153, 152, 145, 143, 142, 135, 134, 133, 125, 124) THEN "At Risk"
                WHEN Segment_code IN (155, 154, 144, 214, 215, 115, 114, 113) THEN "Can't Lose Them"
                WHEN Segment_code IN (332, 322, 231, 241, 251, 233, 232, 223, 222, 132, 123, 122, 212, 211) THEN "Hibernating"
                WHEN Segment_code IN (111, 112, 121, 131, 141, 151) THEN "Lost"
        END Segment
FROM (
    SELECT recently.CustomerID, Score_r, Score_f, Score_m, CAST(CONCAT(Score_r, Score_f,Score_m) AS INT64) AS Segment_code
    FROM recently
    FULL JOIN frequency
        USING(CustomerID)
    FULL JOIN moneytary
        USING(CustomerID))
ORDER BY 1
