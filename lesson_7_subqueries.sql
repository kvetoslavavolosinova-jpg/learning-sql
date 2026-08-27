-- ============================================================
-- LESSON 7: SUBQUERIES
-- ============================================================
-- Topics:
-- 1. What is a subquery?
-- 2. Subqueries with WHERE
-- 3. Subqueries with aggregate functions
-- 4. Subqueries with IN
-- 5. Subqueries with EXISTS
-- 6. Subqueries in SELECT
-- 7. Business analysis
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. BASIC SUBQUERY
-- Find employees earning more than the average salary.
--
-- The inner query calculates the average salary.
-- The outer query finds employees above that average.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);


-- ============================================================
-- 2. SUBQUERY WITH MAX
-- Find employees with the highest salary.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);


-- ============================================================
-- 3. SUBQUERY WITH MIN
-- Find employees with the lowest salary.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);


-- ============================================================
-- 4. SUBQUERY WITH COUNT
-- Find departments that have more than two employees.
-- ============================================================

SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 2;


-- ============================================================
-- 5. SUBQUERY WITH IN
-- Find employees who work in departments that exist
-- in the departments table.
-- ============================================================

SELECT
    name,
    department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
);


-- ============================================================
-- 6. SUBQUERY + JOIN
-- Find employees whose salary is above the company average
-- and display their department.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY e.salary DESC;


-- ============================================================
-- 7. SUBQUERY IN SELECT
-- Display every employee together with the company
-- average salary.
-- ============================================================

SELECT
    name,
    salary,
    (
        SELECT AVG(salary)
        FROM employees
    ) AS average_company_salary
FROM employees;


-- ============================================================
-- 8. CALCULATE THE DIFFERENCE FROM AVERAGE
-- Show how much each employee earns above or below
-- the company average.
-- ============================================================

SELECT
    name,
    salary,
    salary - (
        SELECT AVG(salary)
        FROM employees
    ) AS difference_from_average
FROM employees
ORDER BY difference_from_average DESC;


-- ============================================================
-- 9. EXISTS
-- Find employees whose department exists in the departments table.
-- ============================================================

SELECT
    e.name,
    e.department_id
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.department_id = e.department_id
);


-- ============================================================
-- 10. NOT EXISTS
-- Find employees whose department does not exist
-- in the departments table.
-- ============================================================

SELECT
    e.name,
    e.department_id
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.department_id = e.department_id
);


-- ============================================================
-- 11. BUSINESS ANALYSIS
-- Identify employees who earn more than the average salary.
-- Include a salary category.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary,
    CASE
        WHEN e.salary > (
            SELECT AVG(salary)
            FROM employees
        )
        THEN 'Above Average'
        ELSE 'Average or Below'
    END AS salary_status
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
ORDER BY e.salary DESC;


-- ============================================================
-- 12. ADVANCED BUSINESS ANALYSIS
-- Show employees who earn above average and calculate
-- the difference from the company average.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary,
    e.salary - (
        SELECT AVG(salary)
        FROM employees
    ) AS difference_from_average
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY difference_from_average DESC;


-- ============================================================
-- END OF LESSON 7
-- ============================================================