/* ============================================================
   HR EMPLOYEE ATTRITION ANALYSIS  (MySQL 8+)
   Dataset: IBM HR Analytics Employee Attrition & Performance (Kaggle)
   File:    WA_Fn-UseC_-HR-Employee-Attrition.csv  (1,470 rows, 35 columns)

   Part 1: Create database and table
   Part 2: Load the CSV
   Part 3: Analysis queries (Q1 - Q10, plus 2 bonus)
   Part 4: Export query for Excel / Power BI
   ============================================================ */


/* ------------------------------------------------------------
   PART 1: CREATE DATABASE AND TABLE
   ------------------------------------------------------------ */
CREATE DATABASE IF NOT EXISTS hr;
USE hr;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    Age                      INT,
    Attrition                VARCHAR(3),     -- 'Yes' = left, 'No' = stayed
    BusinessTravel           VARCHAR(30),
    DailyRate                INT,
    Department               VARCHAR(50),
    DistanceFromHome         INT,
    Education                INT,
    EducationField           VARCHAR(50),
    EmployeeCount            INT,
    EmployeeNumber           INT,
    EnvironmentSatisfaction  INT,
    Gender                   VARCHAR(10),
    HourlyRate               INT,
    JobInvolvement           INT,
    JobLevel                 INT,
    JobRole                  VARCHAR(50),
    JobSatisfaction          INT,
    MaritalStatus            VARCHAR(20),
    MonthlyIncome            INT,
    MonthlyRate              INT,
    NumCompaniesWorked       INT,
    Over18                   VARCHAR(1),
    OverTime                 VARCHAR(3),     -- 'Yes' / 'No'
    PercentSalaryHike        INT,
    PerformanceRating        INT,
    RelationshipSatisfaction INT,
    StandardHours            INT,
    StockOptionLevel         INT,
    TotalWorkingYears        INT,
    TrainingTimesLastYear    INT,
    WorkLifeBalance          INT,
    YearsAtCompany           INT,
    YearsInCurrentRole       INT,
    YearsSinceLastPromotion  INT,
    YearsWithCurrManager     INT
);


/* ------------------------------------------------------------
   PART 2: LOAD THE CSV
   Before running:
   1. Change the file path below to where YOU saved the CSV
      (forward slashes, e.g. C:/hr/WA_Fn-UseC_-HR-Employee-Attrition.csv)
   2. Run:  SET GLOBAL local_infile = 1;
      (your Workbench connection already has OPT_LOCAL_INFILE=1)
   3. Run the LOAD DATA block ONCE only.
   The last column is read into @last so a hidden Windows line-ending
   character (\r) is removed automatically.
   ------------------------------------------------------------ */
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/hr/WA_Fn-UseC_-HR-Employee-Attrition.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Age, Attrition, BusinessTravel, DailyRate, Department, DistanceFromHome,
 Education, EducationField, EmployeeCount, EmployeeNumber,
 EnvironmentSatisfaction, Gender, HourlyRate, JobInvolvement, JobLevel,
 JobRole, JobSatisfaction, MaritalStatus, MonthlyIncome, MonthlyRate,
 NumCompaniesWorked, Over18, OverTime, PercentSalaryHike, PerformanceRating,
 RelationshipSatisfaction, StandardHours, StockOptionLevel, TotalWorkingYears,
 TrainingTimesLastYear, WorkLifeBalance, YearsAtCompany, YearsInCurrentRole,
 YearsSinceLastPromotion, @last)
SET YearsWithCurrManager = REPLACE(@last, '\r', '');

-- Check: should return 1470 rows, 237 'Yes' (about 16%) and 1233 'No'
SELECT COUNT(*) AS total_rows FROM employees;
SELECT Attrition, COUNT(*) AS n FROM employees GROUP BY Attrition;


/* ------------------------------------------------------------
   PART 3: ANALYSIS QUERIES
   Attrition rate = employees who left / total employees * 100
   ------------------------------------------------------------ */

-- Q1. Overall KPIs
SELECT
    COUNT(*)                                                        AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct,
    ROUND(AVG(MonthlyIncome), 0)                                    AS avg_monthly_income,
    ROUND(AVG(Age), 1)                                              AS avg_age
FROM employees;


-- Q2. Attrition by department
SELECT
    Department,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY Department
ORDER BY attrition_pct DESC;


-- Q3. Attrition by job role
SELECT
    JobRole,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY JobRole
ORDER BY attrition_pct DESC;


-- Q4. Attrition by age group
SELECT
    CASE
        WHEN Age < 25 THEN '1. Under 25'
        WHEN Age BETWEEN 25 AND 34 THEN '2. 25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '3. 35-44'
        ELSE '4. 45+'
    END                                                             AS age_group,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY age_group
ORDER BY age_group;


-- Q5. Attrition: overtime vs no overtime
SELECT
    OverTime,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY OverTime
ORDER BY attrition_pct DESC;


-- Q6. Average monthly income: employees who stayed vs left
SELECT
    Attrition,
    COUNT(*)                         AS employees,
    ROUND(AVG(MonthlyIncome), 0)     AS avg_monthly_income,
    ROUND(AVG(YearsAtCompany), 1)    AS avg_years_at_company
FROM employees
GROUP BY Attrition;


-- Q7. Attrition by monthly income band
SELECT
    CASE
        WHEN MonthlyIncome < 3000 THEN '1. Under 3,000'
        WHEN MonthlyIncome < 6000 THEN '2. 3,000-5,999'
        WHEN MonthlyIncome < 10000 THEN '3. 6,000-9,999'
        ELSE '4. 10,000+'
    END                                                             AS income_band,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY income_band
ORDER BY income_band;


-- Q8. Attrition by years since last promotion
SELECT
    CASE
        WHEN YearsSinceLastPromotion = 0 THEN '1. Promoted this year'
        WHEN YearsSinceLastPromotion BETWEEN 1 AND 2 THEN '2. 1-2 years ago'
        WHEN YearsSinceLastPromotion BETWEEN 3 AND 5 THEN '3. 3-5 years ago'
        ELSE '4. 6+ years ago'
    END                                                             AS last_promotion,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY last_promotion
ORDER BY last_promotion;


-- Q9. Attrition by job satisfaction (1 = Low, 2 = Medium, 3 = High, 4 = Very High)
SELECT
    JobSatisfaction,
    COUNT(*)                                                        AS employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)              AS left_count,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;


-- Q10. Top 3 job roles by attrition rate within each department
--      (CTE + RANK() window function)
WITH role_stats AS (
    SELECT
        Department,
        JobRole,
        COUNT(*)                                                    AS employees,
        ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 2)                                        AS attrition_pct
    FROM employees
    GROUP BY Department, JobRole
),
ranked AS (
    SELECT
        Department, JobRole, employees, attrition_pct,
        RANK() OVER (PARTITION BY Department ORDER BY attrition_pct DESC) AS rnk
    FROM role_stats
)
SELECT Department, JobRole, employees, attrition_pct, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY Department, rnk;


-- BONUS Q11. Attrition by work-life balance (1 = Bad ... 4 = Best)
SELECT
    WorkLifeBalance,
    COUNT(*)                                                        AS employees,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;


-- BONUS Q12. Attrition by distance from home
SELECT
    CASE
        WHEN DistanceFromHome <= 5 THEN '1. 1-5 km'
        WHEN DistanceFromHome <= 10 THEN '2. 6-10 km'
        WHEN DistanceFromHome <= 20 THEN '3. 11-20 km'
        ELSE '4. 21+ km'
    END                                                             AS distance_band,
    COUNT(*)                                                        AS employees,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                            AS attrition_pct
FROM employees
GROUP BY distance_band
ORDER BY distance_band;


/* ------------------------------------------------------------
   PART 4: EXPORT QUERY FOR EXCEL AND POWER BI
   Run this, click Export above the result grid, and save as
   hr_employees_clean.csv. It keeps only useful columns and adds
   age_group, income_band and a 1/0 attrition flag.
   ------------------------------------------------------------ */
SELECT
    EmployeeNumber,
    Age,
    CASE
        WHEN Age < 25 THEN '1. Under 25'
        WHEN Age BETWEEN 25 AND 34 THEN '2. 25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '3. 35-44'
        ELSE '4. 45+'
    END AS age_group,
    Gender,
    MaritalStatus,
    Department,
    JobRole,
    JobLevel,
    MonthlyIncome,
    CASE
        WHEN MonthlyIncome < 3000 THEN '1. Under 3,000'
        WHEN MonthlyIncome < 6000 THEN '2. 3,000-5,999'
        WHEN MonthlyIncome < 10000 THEN '3. 6,000-9,999'
        ELSE '4. 10,000+'
    END AS income_band,
    OverTime,
    BusinessTravel,
    DistanceFromHome,
    JobSatisfaction,
    WorkLifeBalance,
    YearsAtCompany,
    YearsSinceLastPromotion,
    Attrition,
    CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag
FROM employees;
