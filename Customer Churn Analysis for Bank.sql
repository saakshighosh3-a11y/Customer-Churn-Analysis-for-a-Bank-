CREATE DATABASE customer_churn;
USE customer_churn;
##CALCULATION OF THE TOTAL NUMBER OF CUSTOMERS,EXITED CUSTOMERS AND RETAINED CUSTOMERS
SELECT 
COUNT(*)AS total_customers,
SUM(exited=1)AS exited_customers,
SUM(exited=0)AS retained_customers
FROM customer_churn;
##THE ANALYSIS PROVIDES AN OVERVIEW OF THE BANK'S CUSTOMER BASE BY IDENTIFYING TOTAL,EXITED AND RETAINED CUSTOMERS.
##ALTHOUGH THE RETAINED CUSTOMERS BASE REPRESENTS THE BANK'S EXITING CUSTOMER RELATIONSHIPS,CUSTOMER EXITS HIGHLIGHTS THE NEED FOR A STRUCTURED RETENTION STRAGEGY.
##RECOMMENDATIONS##
#NEED TO CONDUCT A DETAILED ANALYSIS OF EXITED CUSTOMERS TO IDENTIFY THE KEY FACTORS CONTRIBUTING TO ATTRIBUTION.
#INTRODUCTION OF TARGETED CUSTOMER ENAGEMENT INITIATIVES TO IMPROVE RETENTION.
#ANALYSE RETAINED CUSTOMERS TO UNDERSTAND BEHAVIOURAL PATTERNS ASSOCIATED WITH CONTINUED BANKING RELATIONSHIP.


##CALCULATING THE OVERALL CUSTOMER CHURN RATE AND RETENTION RATE
SELECT 
ROUND(AVG(exited)*100,2)AS churn_rate,
ROUND((1-AVG(exited))*100,2)AS retention_rate
FROM customer_churn;


##NAME OF GEOGRAPHY THAT HAS THE HIGHEST CUSTOMER CHURN RATE
SELECT 
geography,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,

ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY geography 
ORDER BY churn_rate DESC;

#ANALYSIS CHURN RATES ACROSS DIFFERENT AGE GROUPS
SELECT
CASE
WHEN age <25 THEN "below 25"
WHEN age BETWEEN 25 AND 35 THEN "25-35"
WHEN age BETWEEN 36 AND 45 THEN "36-45"
WHEN age BETWEEN 46 AND 55 THEN "46-55"
ELSE "Aabove55" 
END AS age_group, 

COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY age_group
ORDER BY churn_rate DESC;


#COMPARE CHURN RATES BETWEEN ACTIVE AND INACTIVE CUSTOMERS
SELECT
isactivemember,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY isactivemember;


#PRODUCT HAVING HIGHEST CHURN RATE 
SELECT
numofproducts,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY numofproducts
ORDER BY churn_rate DESC;


#COMPARING THE AVERAGE BALANCE OF EXITED AND RETAINED CUSTOMERS
SELECT
CASE
WHEN exited=1 THEN "exited"
ELSE "retained"
END AS customer_status,

ROUND(AVG(balance),2)AS average_balance,
ROUND(SUM(balance),2)AS total_balance
FROM customer_churn
GROUP BY exited;


#GENDER HAS THE HIGHEST CHURN RATE
SELECT 
gender,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY gender 
ORDER BY churn_rate DESC;


#DO CUSTOMERS WITH CREDIT CARDS HAVE DIFFERENT CHURN RATES?
SELECT 
hascrcard,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY hascrcard;


#TENURE GROUP HAS THE HIGHEST CHURN RATE
SELECT 
CASE 
WHEN tenure BETWEEN 0 AND 2 THEN "0-2 years"
WHEN tenure BETWEEN 3 AND 5 THEN "3-5 years"
WHEN tenure BETWEEN 6 AND 8 THEN "6-8 years"
ELSE "9-10 years"
END AS tenure_group,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY tenure_group
ORDER BY churn_rate DESC;


#CALCULATION OF TOTAL BALANCE ASSOCITED WITH EXITED CUSTOMERS BY GEOGRAPHY
SELECT 
geography,
COUNT(*)AS exited_customers,
ROUND(SUM(balance),2)AS exited_balance,
ROUND(AVG(balance),2)AS average_balance
FROM customer_churn
WHERE exited=1
GROUP BY geography
ORDER BY exited_balance DESC;


#CALCULATING THE PERCENTAGE OF TOTAL BANK BALANCE ASSOCIATED WITH EXITED CUSTOMERS
SELECT 
ROUND( 
SUM(CASE WHEN exited=1 THEN balance ELSE 0 END)
*100.00/NULLIF(SUM(balance),0),2
)
AS exited_balance_percentage
FROM customer_churn;


#IDENTIFYING CUSTOMERS WHOSE BALANCES ARE ABOVE THE OVERALL AVERAGE AND WHO HAVE EXITED
SELECT
customerId,
geography,
age,
creditscore,
balance,
estimatedsalary
FROM customer_churn
WHERE exited=1
AND balance>(
SELECT AVG(balance)
FROM customer_churn
)
ORDER BY balance DESC;


#CUSTOMERS WHOSE BALANCE IS GREATER THAN THE AVERAGE BALANCE OF THEIR RESPECTIVE GEOGRAPHY 
WITH geography_average AS (
SELECT 
geography,
AVG(balance)AS avg_balance
FROM customer_churn
GROUP BY geography
)
SELECT
b.customerId,
b.geography,
b.balance,
ROUND(g.avg_balance,2)AS geography_avg_balance
FROM customer_churn b

JOIN geography_average g 
ON b.geography=g.geography
WHERE b.balance>g.avg_balance;


#THE TOP 10 CUSTOMERS WITH THE HIGHEST BALANCES WHO HAVE EXITED
SELECT 
customerId,
geography,
age,
balance,
estimatedsalary
FROM customer_churn
WHERE exited=1
ORDER BY balance DESC
LIMIT 10;


#CALCULATING CHURN RATES FOR EACH BALANCE SEGMENT 
WITH customer_segments AS (
SELECT 
balance,
exited,

CASE
WHEN balance>=150000 THEN "high balance"
WHEN balance>=50000 THEN "medium balance"
ELSE "low balance"
END AS balance_segment
FROM customer_churn
)
SELECT 
balance_segment,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_segments
GROUP BY balance_segment
ORDER BY churn_rate DESC;


#INACTIVE CUSTOMERS WHO HAVE HIGH BALANCE AND HAVE EXITED
SELECT 
customerId,
geography,
age,
tenure,
balance,
creditscore
FROM customer_churn
WHERE isactivemember=0
AND exited=1
AND balance>=100000
ORDER BY balance DESC;


#CALCULATING THE CHURN RATE FOR COMBINATION OF GEOGRAPHY AND PRODUCT COUNT
SELECT 
geography,
numofproducts,

COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY geography,
numofproducts
ORDER BY churn_rate DESC;


#IDENTIFYING CUSTOMERS SEGMENTS WITH ABOVE-AVERAGE CHURN AND ATLEAST 50 CUSTOMERS
WITH overall_churn AS(
SELECT AVG(exited)*100 AS churn_rate
FROM customer_churn
),
segment_analysis AS(
SELECT 
geography,
isactivemember,
numofproducts,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
AVG(exited)*100 AS churn_rate
FROM customer_churn
GROUP BY geography,
isactivemember,
numofproducts
HAVING COUNT(*)>=50
)
SELECT
s.*,
ROUND(o.churn_rate,2)AS overall_churn_rate
FROM segment_analysis s 
CROSS JOIN overall_churn o 
WHERE s.churn_rate>o.churn_rate
ORDER BY s.churn_rate DESC;


#RANK GEOGRAPHIES BASED ON CHURN RATE 
WITH geography_churn AS(
SELECT
geography,
COUNT(*)AS total_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM customer_churn
GROUP BY geography
)
SELECT
*,
DENSE_RANK()OVER(
  ORDER BY churn_rate DESC
)AS churn_rank
FROM geography_churn;


#THE TOP 10% OF CUSTOMERS BASED ON BALANCE
WITH customer_rank AS(
SELECT
customerId,
geography,
balance,
NTILE(10)OVER(
ORDER BY balance DESC
)AS balance_decile
FROM customer_churn
)
SELECT *
FROM customer_rank
WHERE balance_decile=1
ORDER BY balance DESC;


#RANK CUSTOMERS BY BALANCE WITHIN EACH GEOGRAPHY
SELECT
customerId,
geography,
balance,
ROW_NUMBER()OVER(
PARTITION BY geography
ORDER BY balance DESC 
)AS customer_rank
FROM customer_churn;


#CALCULATING CUMULATIVE CUSTOMER BALANCE WITHIN EACH GEOGRAPHY
SELECT
customerId,
geography,
balance,

SUM(balance)OVER(
PARTITION BY geography
ORDER BY balance DESC,customerId
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
)AS cumulative_balance
FROM customer_churn;


#CALCULATING THE PERCENTAGE CONTRIBUTION OF EACH GEOGRAPHY TO TOTAL EXITED CUSTOMERS 
WITH geography_exit AS( 
SELECT
geography,
SUM(exited)AS exited_customers
FROM customer_churn
GROUP BY geography
)
SELECT 
geography,
exited_customers,
ROUND(
exited_customers*100.00/
SUM(exited_customers)OVER(),
2
)AS percentage_contribution
FROM geography_exit
ORDER BY percentage_contribution DESC;


#IDENTIFYING CUSTOMERS WHOSE BALANCES EXCEED THEIR GEOGRAPHY'S 75TH PERCENTILE
WITH balance_distribution AS (
SELECT 
customerId,
geography,
balance,
CUME_DIST()OVER( 
PARTITION BY geography 
ORDER BY balance 
)AS balance_distribution
FROM customer_churn
)
SELECT * 
FROM balance_distribution
WHERE balance_distribution>0.75
ORDER BY geography,balance DESC;


#COMPARE EACH CUSTOMER'S BALANCE WITH THEIR GEOGRAPHY'S AVERAGE BALANCE 
SELECT 
customerId,
geography,
balance,
ROUND( 
AVG(balance)OVER(
PARTITION BY geography
),
2
)AS geography_avg_balance,
ROUND( 
balance-AVG(balance)OVER(
PARTITION BY geography
),
2
)AS balance_difference
FROM customer_churn;


#TOP 3 CUSTOMERS BY BALANCE IN EACH GEOGRAPHY
WITH ranked_customers AS ( 
SELECT
customerId,
geography,
balance,
DENSE_RANK()OVER(
PARTITION BY geography
ORDER BY balance DESC 
)AS balance_rank 
FROM customer_churn
)
SELECT * 
FROM ranked_customers
WHERE balance_rank<=3
ORDER BY geography,balance_rank;


#COMPARING CHURN RATES ACROSS CREDIT SCORE BANDS
WITH credit_analysis AS(
SELECT 
CASE 
WHEN creditscore<600 THEN "low"
WHEN creditscore BETWEEN 600 AND 699 THEN "medium"
WHEN creditscore BETWEEN 700 AND 799 THEN "high"
ELSE "very high"
END AS credit_band,

exited
FROM customer_churn 
)
SELECT 
credit_band,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(exited)*100,2)AS churn_rate
FROM credit_analysis
GROUP BY credit_band
ORDER BY churn_rate DESC;


#CREATING A CONSOLIDATED CUSTOMER SEGMENTATION REPORT
WITH customer_segments AS( 
SELECT 
customerId,
geography,
balance,
exited,

CASE 

WHEN balance>=100000
AND isactivemember=1
THEN "high value active"

WHEN balance>=100000
AND isactivemember=0
THEN "high value inactive"
WHEN balance<100000
AND isactivemember=1
THEN "low value active"

ELSE "low balance inactive"
END AS customer_segment
FROM customer_churn
)
SELECT 
customer_segment,
COUNT(*)AS total_customers,
SUM(exited)AS exited_customers,
ROUND(AVG(balance),2)AS average_balance,
ROUND(SUM(balance),2)AS total_balance
FROM customer_segments
GROUP BY customer_segment;
SELECT * FROM customer_churn;



#####ANALYSIS
#1)INVESTIGATING THE REGIONAL CUSTOMER EXPERIENCE AND SERVICE PATTERN
#2)EXAMING THE PRODUCTS NEEDS AND CUSTOMER FEEDBACK
#3)TESTING THE ENAGAGEMENT CAMPAIGNS AND MEASURE THEIR IMPACT
#4)INVESTIGATING WHETHER PRODUCT SUITABILITY OR CUSTOMER EXPERIENCE DIFFER ACROSS GROUPS
#5)EXAMING THE FINANCIAL CHARACTERISTICS OF CHURNED CUSTOMERS AND EVALUATE RETENTION OPPORTUNITIES
#6)INVESTIGATING WHETHER OTHER CUSTOMER CHARACTERISTICS EXPLAIN THE OBSERVED PATTERN











