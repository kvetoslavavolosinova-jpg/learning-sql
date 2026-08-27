-- ============================================================
-- LESSON 9: WINDOW FUNCTIONS
-- ============================================================
-- Topics:
-- 1. ROW_NUMBER()
-- 2. RANK()
-- 3. DENSE_RANK()
-- 4. PARTITION BY
-- 5. Running totals
-- 6. LAG()
-- 7. LEAD()
-- 8. Comparing rows with averages
-- 9. Business analysis
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. ROW_NUMBER()
-- Assign a unique sequential number to each employee
-- based on salary from highest to lowest.
-- ============================================================

SELECT
    name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS salary_position
FROM employees;


-- ============================================================
-- 2. RANK()
-- Rank employees according to salary.
-- Employees with the same salary receive the same rank.
-- ============================================================

SELECT
    name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;


-- ============================================================
-- 3. DENSE_RANK()
-- Rank employees according to salary without gaps
-- between ranking numbers.
-- ============================================================

SELECT
    name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;


-- ============================================================
-- 4. PARTITION BY
-- Rank employees separately within each department.
-- ============================================================

SELECT
    name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS department_salary_rank
FROM employees;


-- ============================================================
-- 5. PARTITION BY + JOIN
-- Display department names and rank employees
-- within their department.
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name,
    e.salary,
    RANK() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS department_salary_rank
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
ORDER BY d.department_name, department_salary_rank;


-- ============================================================
-- 6. RUNNING TOTAL
-- Calculate a cumulative salary total
-- ordered from highest to lowest salary.
-- ============================================================

SELECT
    name,
    salary,
    SUM(salary) OVER (
        ORDER BY salary DESC
    ) AS running_salary_total
FROM employees;


-- ============================================================
-- 7. DEPARTMENT RUNNING TOTAL
-- Calculate a cumulative salary total separately
-- for each department.
-- ============================================================

SELECT
    name,
    department_id,
    salary,
    SUM(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS department_running_total
FROM employees;


-- ============================================================
-- 8. LAG()
-- Compare each employee's salary with the previous salary
-- in descending salary order.
-- ============================================================

SELECT
    name,
    salary,
    LAG(salary) OVER (
        ORDER BY salary DESC
    ) AS previous_salary
FROM employees;


-- ============================================================
-- 9. LEAD()
-- Compare each employee's salary with the next salary
-- in descending salary order.
-- ============================================================

SELECT
    name,
    salary,
    LEAD(salary) OVER (
        ORDER BY salary DESC
    ) AS next_salary
FROM employees;


-- ============================================================
-- 10. SALARY DIFFERENCE
-- Calculate the difference between the current salary
-- and the previous salary.
-- ============================================================

SELECT
    name,
    salary,
    LAG(salary) OVER (
        ORDER BY salary DESC
    ) AS previous_salary,
    salary - LAG(salary) OVER (
        ORDER BY salary DESC
    ) AS salary_difference
FROM employees;


-- ============================================================
-- 11. COMPARE WITH COMPANY AVERAGE
-- Display each employee together with the company average.
-- ============================================================

SELECT
    name,
    salary,
    ROUND(
        AVG(salary) OVER (),
        2
    ) AS company_average_salary
FROM employees;


-- ============================================================
-- 12. DIFFERENCE FROM COMPANY AVERAGE
-- Calculate how far each employee's salary is from
-- the company average.
-- ============================================================

SELECT
    name,
    salary,
    ROUND(
        AVG(salary) OVER (),
        2
    ) AS company_average_salary,
    ROUND(
        salary - AVG(salary) OVER (),
        2
    ) AS difference_from_average
FROM employees
ORDER BY difference_from_average DESC;


-- ============================================================
-- 13. DEPARTMENT AVERAGE
-- Display each employee's salary together with
-- the average salary of their department.
-- ============================================================

SELECT
    name,
    department_id,
    salary,
    ROUND(
        AVG(salary) OVER (
            PARTITION BY department_id
        ),
        2
    ) AS department_average_salary
FROM employees;


-- ============================================================
-- 14. DIFFERENCE FROM DEPARTMENT AVERAGE
-- Calculate the difference between an employee's salary
-- and their department average.
-- ============================================================

SELECT
    name,
    department_id,
    salary,
    ROUND(
        AVG(salary) OVER (
            PARTITION BY department_id
        ),
        2
    ) AS department_average_salary,
    ROUND(
        salary - AVG(salary) OVER (
            PARTITION BY department_id
        ),
        2
    ) AS difference_from_department_average
FROM employees
ORDER BY department_id, difference_from_department_average DESC;


-- ============================================================
-- 15. BUSINESS ANALYSIS
-- Identify the highest-paid employee in each department.
-- ============================================================

WITH ranked_employees AS (
    SELECT
        e.name AS employee_name,
        d.department_name,
        e.salary,
        RANK() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC
        ) AS salary_rank
    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
)

SELECT
    employee_name,
    department_name,
    salary
FROM ranked_employees
WHERE salary_rank = 1
ORDER BY salary DESC;


-- ============================================================
-- 16. BUSINESS REPORT
-- Create a complete employee salary ranking report.
-- ============================================================

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
    ) AS department_salary_rank,

    ROUND(
        AVG(e.salary) OVER (),
        2
    ) AS company_average_salary,

    ROUND(
        AVG(e.salary) OVER (
            PARTITION BY e.department_id
        ),
        2
    ) AS department_average_salary

FROM employees e
JOIN departments d
    ON e.department_id = d.department_id

ORDER BY e.salary DESC;


-- ============================================================
-- END OF LESSON 9
-- ============================================================