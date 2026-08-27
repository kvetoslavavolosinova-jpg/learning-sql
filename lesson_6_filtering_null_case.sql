-- ============================================================
-- LESSON 6: FILTERING, NULL & CASE
-- ============================================================
-- Topics:
-- 1. WHERE
-- 2. Comparison Operators
-- 3. AND / OR / NOT
-- 4. IN
-- 5. BETWEEN
-- 6. LIKE
-- 7. NULL
-- 8. CASE WHEN
-- 9. Combining Filters with JOINs
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. WHERE
-- Filter employees by department.
-- ============================================================

SELECT *
FROM employees
WHERE department_id = 1;


-- ============================================================
-- 2. COMPARISON OPERATORS
-- Find employees with a salary greater than 50,000.
-- ============================================================

SELECT *
FROM employees
WHERE salary > 50000;


-- ============================================================
-- 3. AND
-- Find employees who work in department 2
-- AND earn more than 40,000.
-- ============================================================

SELECT *
FROM employees
WHERE department_id = 2
AND salary > 40000;


-- ============================================================
-- 4. OR
-- Find employees who work in department 1 or department 3.
-- ============================================================

SELECT *
FROM employees
WHERE department_id = 1
OR department_id = 3;


-- ============================================================
-- 5. IN
-- The IN operator is a shorter alternative to multiple OR conditions.
-- ============================================================

SELECT *
FROM employees
WHERE department_id IN (1, 2, 3);


-- ============================================================
-- 6. BETWEEN
-- Find employees with salaries between 40,000 and 60,000.
-- ============================================================

SELECT *
FROM employees
WHERE salary BETWEEN 40000 AND 60000;


-- ============================================================
-- 7. LIKE
-- Find employees whose names start with the letter A.
-- ============================================================

SELECT *
FROM employees
WHERE name LIKE 'A%';


-- ============================================================
-- 8. NULL
-- Find employees where a specific column has no value.
--
-- Replace "column_name" with a column from your database
-- that contains NULL values.
-- ============================================================

-- SELECT *
-- FROM employees
-- WHERE column_name IS NULL;


-- ============================================================
-- 9. IS NOT NULL
-- Find employees where a specific column contains a value.
-- ============================================================

-- SELECT *
-- FROM employees
-- WHERE column_name IS NOT NULL;


-- ============================================================
-- 10. CASE WHEN
-- Categorize employees according to salary.
-- ============================================================

SELECT
    name,
    salary,
    CASE
        WHEN salary >= 60000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;


-- ============================================================
-- 11. CASE + ORDER BY
-- Display employees from the highest to the lowest salary.
-- ============================================================

SELECT
    name,
    salary,
    CASE
        WHEN salary >= 60000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees
ORDER BY salary DESC;


-- ============================================================
-- 12. JOIN + WHERE
-- Combine employees with their departments
-- and filter the results.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE e.salary > 40000;


-- ============================================================
-- 13. JOIN + CASE
-- Combine employee information with salary categorization.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary,
    CASE
        WHEN e.salary >= 60000 THEN 'High'
        WHEN e.salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
ORDER BY e.salary DESC;


-- ============================================================
-- 14. BUSINESS ANALYSIS
-- Identify employees earning more than 50,000
-- and categorize their salary level.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary,
    CASE
        WHEN e.salary >= 70000 THEN 'High'
        WHEN e.salary >= 50000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;


-- ============================================================
-- END OF LESSON 6
-- ============================================================