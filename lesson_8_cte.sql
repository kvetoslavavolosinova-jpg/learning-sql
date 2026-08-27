-- ============================================================
-- LESSON 8: COMMON TABLE EXPRESSIONS (CTEs)
-- ============================================================
-- Topics:
-- 1. Basic CTE
-- 2. CTE with aggregation
-- 3. CTE with filtering
-- 4. Multiple CTEs
-- 5. CTE with JOINs
-- 6. CTE with CASE
-- 7. Business analysis
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. BASIC CTE
-- Calculate the average company salary first,
-- then use it in the main query.
-- ============================================================

WITH average_salary AS (
    SELECT AVG(salary) AS avg_salary
    FROM employees
)

SELECT
    e.name,
    e.salary,
    a.avg_salary
FROM employees e
CROSS JOIN average_salary a;


-- ============================================================
-- 2. CTE WITH FILTERING
-- Find employees earning above the company average.
-- ============================================================

WITH average_salary AS (
    SELECT AVG(salary) AS avg_salary
    FROM employees
)

SELECT
    e.name,
    e.salary
FROM employees e
CROSS JOIN average_salary a
WHERE e.salary > a.avg_salary
ORDER BY e.salary DESC;


-- ============================================================
-- 3. CTE WITH AGGREGATION
-- Calculate the average salary for each department.
-- ============================================================

WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)

SELECT *
FROM department_salary
ORDER BY average_salary DESC;


-- ============================================================
-- 4. CTE + JOIN
-- Display department names together with average salary.
-- ============================================================

WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)

SELECT
    d.department_name,
    ds.average_salary
FROM department_salary ds
JOIN departments d
    ON ds.department_id = d.department_id
ORDER BY ds.average_salary DESC;


-- ============================================================
-- 5. MULTIPLE CTEs
-- First calculate department salary statistics.
-- Then identify departments with an average salary
-- above the company average.
-- ============================================================

WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS average_department_salary
    FROM employees
    GROUP BY department_id
),

company_salary AS (
    SELECT
        AVG(salary) AS average_company_salary
    FROM employees
)

SELECT
    d.department_name,
    ds.average_department_salary,
    cs.average_company_salary
FROM department_salary ds
JOIN departments d
    ON ds.department_id = d.department_id
CROSS JOIN company_salary cs
WHERE ds.average_department_salary > cs.average_company_salary
ORDER BY ds.average_department_salary DESC;


-- ============================================================
-- 6. CTE + CASE
-- Categorize departments according to their average salary.
-- ============================================================

WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
)

SELECT
    d.department_name,
    ds.average_salary,
    CASE
        WHEN ds.average_salary >= 60000 THEN 'High'
        WHEN ds.average_salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM department_salary ds
JOIN departments d
    ON ds.department_id = d.department_id
ORDER BY ds.average_salary DESC;


-- ============================================================
-- 7. CTE FOR EMPLOYEE PERFORMANCE
-- Calculate salary difference from the company average.
-- ============================================================

WITH company_average AS (
    SELECT
        AVG(salary) AS average_salary
    FROM employees
)

SELECT
    e.name,
    e.salary,
    e.salary - ca.average_salary AS difference_from_average
FROM employees e
CROSS JOIN company_average ca
ORDER BY difference_from_average DESC;


-- ============================================================
-- 8. MULTIPLE CTEs + JOIN
-- Create department-level salary statistics
-- and compare them with the company average.
-- ============================================================

WITH department_stats AS (
    SELECT
        department_id,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary,
        MAX(salary) AS maximum_salary,
        MIN(salary) AS minimum_salary
    FROM employees
    GROUP BY department_id
),

company_stats AS (
    SELECT
        AVG(salary) AS company_average_salary
    FROM employees
)

SELECT
    d.department_name,
    ds.employee_count,
    ds.average_salary,
    ds.maximum_salary,
    ds.minimum_salary,
    cs.company_average_salary,
    ds.average_salary - cs.company_average_salary
        AS difference_from_company_average
FROM department_stats ds
JOIN departments d
    ON ds.department_id = d.department_id
CROSS JOIN company_stats cs
ORDER BY difference_from_company_average DESC;


-- ============================================================
-- 9. BUSINESS ANALYSIS
-- Identify departments whose average salary
-- is above the company average.
-- ============================================================

WITH department_stats AS (
    SELECT
        department_id,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
),

company_average AS (
    SELECT
        AVG(salary) AS average_salary
    FROM employees
)

SELECT
    d.department_name,
    ds.employee_count,
    ds.average_salary,
    CASE
        WHEN ds.average_salary > ca.average_salary
            THEN 'Above Company Average'
        ELSE 'Average or Below'
    END AS department_status
FROM department_stats ds
JOIN departments d
    ON ds.department_id = d.department_id
CROSS JOIN company_average ca
ORDER BY ds.average_salary DESC;


-- ============================================================
-- 10. BUSINESS REPORT
-- Create a clean department salary report.
-- ============================================================

WITH department_stats AS (
    SELECT
        department_id,
        COUNT(*) AS employee_count,
        ROUND(AVG(salary), 2) AS average_salary,
        MAX(salary) AS highest_salary,
        MIN(salary) AS lowest_salary
    FROM employees
    GROUP BY department_id
)

SELECT
    d.department_name,
    ds.employee_count,
    ds.average_salary,
    ds.highest_salary,
    ds.lowest_salary
FROM department_stats ds
JOIN departments d
    ON ds.department_id = d.department_id
ORDER BY ds.average_salary DESC;


-- ============================================================
-- END OF LESSON 8
-- ============================================================