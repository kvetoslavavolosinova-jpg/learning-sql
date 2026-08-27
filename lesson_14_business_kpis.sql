-- ============================================================
-- LESSON 14: BUSINESS KPIs & AGGREGATIONS
-- ============================================================
-- Topics:
-- 1. COUNT
-- 2. SUM
-- 3. AVG
-- 4. MIN / MAX
-- 5. GROUP BY
-- 6. HAVING
-- 7. Percentages
-- 8. Supplier KPIs
-- 9. Delivery KPIs
-- 10. Compliance KPIs
-- 11. Management reporting
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. COUNT
-- Count all employees.
-- ============================================================

SELECT
    COUNT(*) AS total_employees
FROM employees;


-- ============================================================
-- 2. COUNT BY DEPARTMENT
-- Count employees in each department.
-- ============================================================

SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;


-- ============================================================
-- 3. AVERAGE SALARY
-- ============================================================

SELECT
    ROUND(AVG(salary), 2) AS average_salary
FROM employees;


-- ============================================================
-- 4. MINIMUM AND MAXIMUM SALARY
-- ============================================================

SELECT
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees;


-- ============================================================
-- 5. SALARY STATISTICS BY DEPARTMENT
-- ============================================================

SELECT
    department_id,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM employees
GROUP BY department_id
ORDER BY average_salary DESC;


-- ============================================================
-- 6. JOIN + AGGREGATION
-- Display department names instead of IDs.
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.name) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;


-- ============================================================
-- 7. HAVING
-- Find departments with more than two employees.
-- ============================================================

SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 2;


-- ============================================================
-- 8. HAVING + AVERAGE
-- Find departments with an average salary above 50000.
-- ============================================================

SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 50000;


-- ============================================================
-- 9. SUPPLIER DATASET
-- Create a small supplier performance dataset.
-- ============================================================

WITH supplier_performance AS (
    SELECT
        'SUP001' AS supplier_id,
        'Supplier A' AS supplier_name,
        'DE' AS country,
        95 AS s_rating,
        100 AS orders,
        96 AS on_time_deliveries

    UNION ALL

    SELECT
        'SUP002',
        'Supplier B',
        'CZ',
        82,
        80,
        72

    UNION ALL

    SELECT
        'SUP003',
        'Supplier C',
        'ES',
        58,
        60,
        42

    UNION ALL

    SELECT
        'SUP004',
        'Supplier D',
        'SK',
        74,
        90,
        81

    UNION ALL

    SELECT
        'SUP005',
        'Supplier E',
        'AT',
        91,
        120,
        118
)

SELECT
    *
FROM supplier_performance;


-- ============================================================
-- 10. ON-TIME DELIVERY RATE
-- Calculate the percentage of deliveries made on time.
-- ============================================================

WITH supplier_performance AS (
    SELECT 'SUP001' AS supplier_id, 100 AS orders, 96 AS on_time_deliveries
    UNION ALL
    SELECT 'SUP002', 80, 72
    UNION ALL
    SELECT 'SUP003', 60, 42
    UNION ALL
    SELECT 'SUP004', 90, 81
    UNION ALL
    SELECT 'SUP005', 120, 118
)

SELECT
    supplier_id,
    orders,
    on_time_deliveries,

    ROUND(
        on_time_deliveries * 100.0 / orders,
        2
    ) AS on_time_delivery_rate

FROM supplier_performance;


-- ============================================================
-- 11. SUPPLIER PERFORMANCE CLASSIFICATION
-- ============================================================

WITH supplier_performance AS (
    SELECT 'SUP001' AS supplier_id, 'Supplier A' AS supplier_name,
           95 AS s_rating, 100 AS orders, 96 AS on_time_deliveries

    UNION ALL

    SELECT 'SUP002', 'Supplier B',
           82, 80, 72

    UNION ALL

    SELECT 'SUP003', 'Supplier C',
           58, 60, 42

    UNION ALL

    SELECT 'SUP004', 'Supplier D',
           74, 90, 81

    UNION ALL

    SELECT 'SUP005', 'Supplier E',
           91, 120, 118
)

SELECT
    supplier_id,
    supplier_name,
    s_rating,

    ROUND(
        on_time_deliveries * 100.0 / orders,
        2
    ) AS on_time_delivery_rate,

    CASE
        WHEN s_rating >= 80
         AND on_time_deliveries * 100.0 / orders >= 95
            THEN 'Excellent'

        WHEN s_rating >= 70
         AND on_time_deliveries * 100.0 / orders >= 90
            THEN 'Good'

        WHEN s_rating >= 60
         AND on_time_deliveries * 100.0 / orders >= 80
            THEN 'Needs Improvement'

        ELSE 'High Risk'
    END AS supplier_performance

FROM supplier_performance

ORDER BY
    on_time_delivery_rate DESC;


-- ============================================================
-- 12. OVERALL SUPPLIER KPIs
-- ============================================================

WITH supplier_performance AS (
    SELECT 'SUP001' AS supplier_id, 95 AS s_rating,
           100 AS orders, 96 AS on_time_deliveries

    UNION ALL
    SELECT 'SUP002', 82, 80, 72

    UNION ALL
    SELECT 'SUP003', 58, 60, 42

    UNION ALL
    SELECT 'SUP004', 74, 90, 81

    UNION ALL
    SELECT 'SUP005', 91, 120, 118
)

SELECT
    COUNT(*) AS total_suppliers,

    ROUND(
        AVG(s_rating),
        2
    ) AS average_s_rating,

    SUM(orders) AS total_orders,

    SUM(on_time_deliveries) AS total_on_time_deliveries,

    ROUND(
        SUM(on_time_deliveries) * 100.0
        / SUM(orders),
        2
    ) AS overall_on_time_delivery_rate

FROM supplier_performance;


-- ============================================================
-- 13. COMPLIANCE RATE
-- Count suppliers with S-Rating >= 80.
-- ============================================================

WITH supplier_performance AS (
    SELECT 'SUP001' AS supplier_id, 95 AS s_rating
    UNION ALL
    SELECT 'SUP002', 82
    UNION ALL
    SELECT 'SUP003', 58
    UNION ALL
    SELECT 'SUP004', 74
    UNION ALL
    SELECT 'SUP005', 91
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN s_rating >= 80 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS compliance_rate
FROM supplier_performance;


-- ============================================================
-- 14. RISK RATE
-- Count suppliers with S-Rating below 60.
-- ============================================================

WITH supplier_performance AS (
    SELECT 'SUP001' AS supplier_id, 95 AS s_rating
    UNION ALL
    SELECT 'SUP002', 82
    UNION ALL
    SELECT 'SUP003', 58
    UNION ALL
    SELECT 'SUP004', 74
    UNION ALL
    SELECT 'SUP005', 91
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN s_rating < 60 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS high_risk_rate
FROM supplier_performance;


-- ============================================================
-- 15. COUNTRY PERFORMANCE
-- Calculate supplier KPIs by country.
-- ============================================================

WITH supplier_performance AS (
    SELECT 'Supplier A' AS supplier_name, 'DE' AS country,
           95 AS s_rating, 100 AS orders, 96 AS on_time_deliveries

    UNION ALL

    SELECT 'Supplier B', 'CZ',
           82, 80, 72

    UNION ALL

    SELECT 'Supplier C', 'ES',
           58, 60, 42

    UNION ALL

    SELECT 'Supplier D', 'SK',
           74, 90, 81

    UNION ALL

    SELECT 'Supplier E', 'AT',
           91, 120, 118
)

SELECT
    country,

    COUNT(*) AS supplier_count,

    ROUND(
        AVG(s_rating),
        2
    ) AS average_s_rating,

    SUM(orders) AS total_orders,

    ROUND(
        SUM(on_time_deliveries) * 100.0
        / SUM(orders),
        2
    ) AS on_time_delivery_rate

FROM supplier_performance

GROUP BY country

ORDER BY on_time_delivery_rate DESC;


-- ============================================================
-- 16. MANAGEMENT KPI REPORT
-- Create a concise supplier performance report.
-- ============================================================

WITH supplier_performance AS (
    SELECT 'SUP001' AS supplier_id, 'Supplier A' AS supplier_name,
           'DE' AS country, 95 AS s_rating,
           100 AS orders, 96 AS on_time_deliveries

    UNION ALL

    SELECT 'SUP002', 'Supplier B',
           'CZ', 82, 80, 72

    UNION ALL

    SELECT 'SUP003', 'Supplier C',
           'ES', 58, 60, 42

    UNION ALL

    SELECT 'SUP004', 'Supplier D',
           'SK', 74, 90, 81

    UNION ALL

    SELECT 'SUP005', 'Supplier E',
           'AT', 91, 120, 118
)

SELECT
    supplier_id,
    supplier_name,
    country,
    s_rating,

    orders,

    ROUND(
        on_time_deliveries * 100.0 / orders,
        2
    ) AS on_time_delivery_rate,

    CASE
        WHEN s_rating >= 80
         AND on_time_deliveries * 100.0 / orders >= 95
            THEN 'Excellent'

        WHEN s_rating >= 70
         AND on_time_deliveries * 100.0 / orders >= 90
            THEN 'Good'

        WHEN s_rating >= 60
         AND on_time_deliveries * 100.0 / orders >= 80
            THEN 'Needs Improvement'

        ELSE 'High Risk'
    END AS performance_status

FROM supplier_performance

ORDER BY
    CASE performance_status
        WHEN 'High Risk' THEN 1
        WHEN 'Needs Improvement' THEN 2
        WHEN 'Good' THEN 3
        WHEN 'Excellent' THEN 4
    END;


-- ============================================================
-- END OF LESSON 14
-- ============================================================