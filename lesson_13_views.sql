-- ============================================================
-- LESSON 13: SQL VIEWS
-- ============================================================
-- Topics:
-- 1. What is a VIEW?
-- 2. Creating a VIEW
-- 3. Querying a VIEW
-- 4. Updating a VIEW
-- 5. Dropping a VIEW
-- 6. Business reporting
-- 7. Supplier compliance reporting
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. BASIC VIEW
-- Create a reusable view containing employee information.
-- ============================================================

DROP VIEW IF EXISTS employee_overview;

CREATE VIEW employee_overview AS
SELECT
    e.name AS employee_name,
    e.salary,
    d.department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;


-- ============================================================
-- 2. QUERY THE VIEW
-- ============================================================

SELECT
    *
FROM employee_overview;


-- ============================================================
-- 3. FILTER A VIEW
-- Find employees earning more than 50000.
-- ============================================================

SELECT
    employee_name,
    department_name,
    salary
FROM employee_overview
WHERE salary > 50000
ORDER BY salary DESC;


-- ============================================================
-- 4. SORT A VIEW
-- Display employees from highest to lowest salary.
-- ============================================================

SELECT
    *
FROM employee_overview
ORDER BY salary DESC;


-- ============================================================
-- 5. CREATE A DEPARTMENT REPORT VIEW
-- ============================================================

DROP VIEW IF EXISTS department_salary_report;

CREATE VIEW department_salary_report AS
SELECT
    d.department_name,
    COUNT(e.name) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    MAX(e.salary) AS highest_salary,
    MIN(e.salary) AS lowest_salary
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;


-- ============================================================
-- 6. QUERY THE DEPARTMENT REPORT
-- ============================================================

SELECT
    *
FROM department_salary_report
ORDER BY average_salary DESC;


-- ============================================================
-- 7. FILTER DEPARTMENT REPORT
-- Find departments with an average salary above 50000.
-- ============================================================

SELECT
    department_name,
    employee_count,
    average_salary
FROM department_salary_report
WHERE average_salary > 50000
ORDER BY average_salary DESC;


-- ============================================================
-- 8. CREATE A RANKING VIEW
-- Create a reusable employee ranking report.
-- ============================================================

DROP VIEW IF EXISTS employee_salary_ranking;

CREATE VIEW employee_salary_ranking AS
SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary,

    RANK() OVER (
        ORDER BY e.salary DESC
    ) AS company_salary_rank,

    RANK() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS department_salary_rank

FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;


-- ============================================================
-- 9. QUERY THE RANKING VIEW
-- ============================================================

SELECT
    *
FROM employee_salary_ranking
ORDER BY company_salary_rank;


-- ============================================================
-- 10. BUSINESS REPORT
-- Show the highest-paid employee in each department.
-- ============================================================

SELECT
    employee_name,
    department_name,
    salary
FROM employee_salary_ranking
WHERE department_salary_rank = 1
ORDER BY salary DESC;


-- ============================================================
-- 11. SUPPLIER COMPLIANCE VIEW
--
-- This is a simulated supplier dataset representing
-- the type of data we will use in the portfolio project.
-- ============================================================

DROP VIEW IF EXISTS supplier_compliance_report;

CREATE VIEW supplier_compliance_report AS

WITH suppliers AS (
    SELECT
        'SUP001' AS supplier_id,
        'Skoda Auto Supplier' AS supplier_name,
        'DE' AS country_code,
        '123456789' AS duns_number,
        92 AS s_rating

    UNION ALL

    SELECT
        'SUP002',
        'Supplier ABC',
        'CZ',
        '234567891',
        78

    UNION ALL

    SELECT
        'SUP003',
        'Supplier XYZ',
        'ES',
        NULL,
        55

    UNION ALL

    SELECT
        'SUP004',
        'Supplier DEF',
        'SK',
        '456789123',
        NULL

    UNION ALL

    SELECT
        'SUP005',
        'Supplier GHI',
        'AT',
        '567891234',
        88
)

SELECT
    supplier_id,
    supplier_name,
    country_code,
    duns_number,
    s_rating,

    CASE
        WHEN s_rating IS NULL
            THEN 'Missing'
        WHEN s_rating >= 80
            THEN 'Compliant'
        WHEN s_rating >= 60
            THEN 'Review Required'
        ELSE 'High Risk'
    END AS compliance_status,

    CASE
        WHEN duns_number IS NULL
            THEN 'Missing'
        ELSE 'Complete'
    END AS duns_status,

    CASE
        WHEN duns_number IS NULL
          OR s_rating IS NULL
          OR s_rating < 60
            THEN 'ACTION REQUIRED'
        ELSE 'OK'
    END AS supplier_action

FROM suppliers;


-- ============================================================
-- 12. QUERY SUPPLIER COMPLIANCE VIEW
-- ============================================================

SELECT
    *
FROM supplier_compliance_report;


-- ============================================================
-- 13. FIND HIGH-RISK SUPPLIERS
-- ============================================================

SELECT
    supplier_id,
    supplier_name,
    country_code,
    s_rating,
    compliance_status,
    supplier_action
FROM supplier_compliance_report
WHERE compliance_status = 'High Risk';


-- ============================================================
-- 14. FIND SUPPLIERS REQUIRING ACTION
-- ============================================================

SELECT
    supplier_id,
    supplier_name,
    duns_number,
    s_rating,
    compliance_status,
    duns_status,
    supplier_action
FROM supplier_compliance_report
WHERE supplier_action = 'ACTION REQUIRED';


-- ============================================================
-- 15. SUPPLIER COMPLIANCE SUMMARY
-- Count suppliers by compliance status.
-- ============================================================

SELECT
    compliance_status,
    COUNT(*) AS supplier_count
FROM supplier_compliance_report
GROUP BY compliance_status
ORDER BY supplier_count DESC;


-- ============================================================
-- 16. DATA QUALITY SUMMARY
-- Count suppliers by DUNS data quality.
-- ============================================================

SELECT
    duns_status,
    COUNT(*) AS supplier_count
FROM supplier_compliance_report
GROUP BY duns_status;


-- ============================================================
-- 17. BUSINESS KPI
-- Calculate supplier compliance percentage.
-- ============================================================

SELECT
    ROUND(
        SUM(
            CASE
                WHEN compliance_status = 'Compliant'
                    THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS compliance_percentage
FROM supplier_compliance_report;


-- ============================================================
-- 18. BUSINESS KPI
-- Calculate percentage of suppliers requiring action.
-- ============================================================

SELECT
    ROUND(
        SUM(
            CASE
                WHEN supplier_action = 'ACTION REQUIRED'
                    THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS action_required_percentage
FROM supplier_compliance_report;


-- ============================================================
-- 19. FINAL MANAGEMENT REPORT
-- Create a concise supplier management view.
-- ============================================================

SELECT
    supplier_id,
    supplier_name,
    country_code,
    s_rating,
    compliance_status,
    duns_status,
    supplier_action
FROM supplier_compliance_report
ORDER BY
    CASE supplier_action
        WHEN 'ACTION REQUIRED' THEN 1
        ELSE 2
    END,
    s_rating ASC;


-- ============================================================
-- 20. DROP VIEW EXAMPLE
-- Do NOT execute this for the views above unless
-- you intentionally want to remove them.
--
-- DROP VIEW IF EXISTS employee_overview;
-- ============================================================


-- ============================================================
-- END OF LESSON 13
-- ============================================================