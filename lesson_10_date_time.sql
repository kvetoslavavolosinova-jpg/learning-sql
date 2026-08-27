-- ============================================================
-- LESSON 10: DATE & TIME FUNCTIONS
-- ============================================================
-- Topics:
-- 1. Current date
-- 2. Extracting date components
-- 3. Date differences
-- 4. Date calculations
-- 5. Date filtering
-- 6. Sorting by dates
-- 7. Business analysis
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. CURRENT DATE
-- Display the current date.
-- ============================================================

SELECT DATE('now') AS current_date;


-- ============================================================
-- 2. CURRENT DATE AND TIME
-- Display the current date and time.
-- ============================================================

SELECT DATETIME('now') AS current_datetime;


-- ============================================================
-- 3. DATE COMPONENTS
-- Extract year, month and day from a date.
-- ============================================================

SELECT
    DATE('2026-08-27') AS date_value,
    STRFTIME('%Y', '2026-08-27') AS year,
    STRFTIME('%m', '2026-08-27') AS month,
    STRFTIME('%d', '2026-08-27') AS day;


-- ============================================================
-- 4. DATE DIFFERENCE
-- Calculate the number of days between two dates.
-- ============================================================

SELECT
    JULIANDAY('2026-09-10') - JULIANDAY('2026-09-01')
        AS days_difference;


-- ============================================================
-- 5. DATE ADDITION
-- Add days to a date.
-- ============================================================

SELECT
    DATE('2026-08-27', '+30 days') AS future_date;


-- ============================================================
-- 6. DATE SUBTRACTION
-- Subtract days from a date.
-- ============================================================

SELECT
    DATE('2026-08-27', '-30 days') AS previous_date;


-- ============================================================
-- 7. MONTH CALCULATION
-- Add one month to a date.
-- ============================================================

SELECT
    DATE('2026-08-27', '+1 month') AS next_month;


-- ============================================================
-- 8. DATE FILTERING
-- Filter records using a date condition.
--
-- This example assumes a column called hire_date.
-- If your employees table does not contain hire_date,
-- keep this query commented out.
-- ============================================================

-- SELECT
--     name,
--     hire_date
-- FROM employees
-- WHERE hire_date >= '2020-01-01';


-- ============================================================
-- 9. SORTING BY DATE
-- Display records from the newest to the oldest.
-- ============================================================

-- SELECT
--     name,
--     hire_date
-- FROM employees
-- ORDER BY hire_date DESC;


-- ============================================================
-- 10. DATE RANGE
-- Find records between two dates.
-- ============================================================

-- SELECT
--     name,
--     hire_date
-- FROM employees
-- WHERE hire_date BETWEEN '2020-01-01' AND '2025-12-31';


-- ============================================================
-- 11. YEAR FILTER
-- Find employees who joined during a specific year.
-- ============================================================

-- SELECT
--     name,
--     hire_date
-- FROM employees
-- WHERE STRFTIME('%Y', hire_date) = '2024';


-- ============================================================
-- 12. MONTH FILTER
-- Find employees who joined during a specific month.
-- ============================================================

-- SELECT
--     name,
--     hire_date
-- FROM employees
-- WHERE STRFTIME('%m', hire_date) = '01';


-- ============================================================
-- 13. BUSINESS CONCEPT: LEAD TIME
--
-- Lead time is the number of days between two events.
--
-- Example:
-- Order date → Delivery date
--
-- The following example uses literal dates so that it can
-- run independently of the current database structure.
-- ============================================================

SELECT
    '2026-08-01' AS order_date,
    '2026-08-08' AS delivery_date,
    JULIANDAY('2026-08-08') - JULIANDAY('2026-08-01')
        AS lead_time_days;


-- ============================================================
-- 14. BUSINESS CONCEPT: DELIVERY DELAY
--
-- Compare the actual delivery date with the expected
-- delivery date.
-- ============================================================

SELECT
    '2026-08-10' AS expected_delivery,
    '2026-08-14' AS actual_delivery,
    JULIANDAY('2026-08-14') - JULIANDAY('2026-08-10')
        AS delay_days;


-- ============================================================
-- 15. BUSINESS CLASSIFICATION
-- Categorize delivery performance.
-- ============================================================

SELECT
    '2026-08-10' AS expected_delivery,
    '2026-08-14' AS actual_delivery,

    JULIANDAY('2026-08-14') - JULIANDAY('2026-08-10')
        AS delay_days,

    CASE
        WHEN JULIANDAY('2026-08-14') - JULIANDAY('2026-08-10') <= 0
            THEN 'On Time'
        WHEN JULIANDAY('2026-08-14') - JULIANDAY('2026-08-10') <= 3
            THEN 'Minor Delay'
        ELSE 'Significant Delay'
    END AS delivery_status;


-- ============================================================
-- 16. BUSINESS ANALYSIS
-- Calculate lead time and classify the result.
-- ============================================================

SELECT
    '2026-08-01' AS order_date,
    '2026-08-09' AS delivery_date,

    JULIANDAY('2026-08-09') - JULIANDAY('2026-08-01')
        AS lead_time_days,

    CASE
        WHEN JULIANDAY('2026-08-09') - JULIANDAY('2026-08-01') <= 3
            THEN 'Short Lead Time'
        WHEN JULIANDAY('2026-08-09') - JULIANDAY('2026-08-01') <= 7
            THEN 'Normal Lead Time'
        ELSE 'Long Lead Time'
    END AS lead_time_category;


-- ============================================================
-- 17. DATE + CASE
-- Classify a delivery based on delay.
-- ============================================================

SELECT
    'Supplier A' AS supplier,
    '2026-08-10' AS expected_delivery,
    '2026-08-12' AS actual_delivery,

    JULIANDAY('2026-08-12') - JULIANDAY('2026-08-10')
        AS delay_days,

    CASE
        WHEN JULIANDAY('2026-08-12') <= JULIANDAY('2026-08-10')
            THEN 'On Time'
        WHEN JULIANDAY('2026-08-12') - JULIANDAY('2026-08-10') <= 3
            THEN 'Minor Delay'
        ELSE 'Significant Delay'
    END AS delivery_status;


-- ============================================================
-- 18. SUPPLY CHAIN EXAMPLE
-- Compare several hypothetical suppliers.
-- ============================================================

WITH deliveries AS (
    SELECT 'Supplier A' AS supplier,
           '2026-08-01' AS expected_date,
           '2026-08-01' AS actual_date

    UNION ALL

    SELECT 'Supplier B',
           '2026-08-01',
           '2026-08-03'

    UNION ALL

    SELECT 'Supplier C',
           '2026-08-01',
           '2026-08-08'
)

SELECT
    supplier,
    expected_date,
    actual_date,

    JULIANDAY(actual_date) - JULIANDAY(expected_date)
        AS delay_days,

    CASE
        WHEN JULIANDAY(actual_date) <= JULIANDAY(expected_date)
            THEN 'On Time'
        WHEN JULIANDAY(actual_date) - JULIANDAY(expected_date) <= 3
            THEN 'Minor Delay'
        ELSE 'Significant Delay'
    END AS delivery_status

FROM deliveries
ORDER BY delay_days DESC;


-- ============================================================
-- END OF LESSON 10
-- ============================================================