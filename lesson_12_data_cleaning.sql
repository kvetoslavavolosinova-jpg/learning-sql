-- ============================================================
-- LESSON 12: DATA CLEANING & DATA QUALITY
-- ============================================================
-- Topics:
-- 1. Identifying NULL values
-- 2. Handling NULL values
-- 3. Detecting duplicates
-- 4. Standardizing text
-- 5. Validating values
-- 6. Creating data quality flags
-- 7. Measuring data completeness
-- 8. Supplier master-data examples
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. IDENTIFY NULL VALUES
-- Find employees without a manager.
-- ============================================================

SELECT
    *
FROM employees
WHERE manager IS NULL;


-- ============================================================
-- 2. IDENTIFY NON-NULL VALUES
-- Find employees who have a manager.
-- ============================================================

SELECT
    *
FROM employees
WHERE manager IS NOT NULL;


-- ============================================================
-- 3. REPLACE NULL VALUES
-- Replace missing manager information with 'Not Assigned'.
-- ============================================================

SELECT
    name,
    COALESCE(manager, 'Not Assigned') AS manager
FROM employees;


-- ============================================================
-- 4. DATA QUALITY FLAG
-- Create a status showing whether manager information exists.
-- ============================================================

SELECT
    name,
    manager,
    CASE
        WHEN manager IS NULL THEN 'Missing'
        ELSE 'Complete'
    END AS manager_data_status
FROM employees;


-- ============================================================
-- 5. DETECT DUPLICATES
-- Create a sample supplier dataset containing duplicates.
-- ============================================================

WITH suppliers AS (
    SELECT 'SUP001' AS supplier_id, 'Skoda Auto' AS supplier_name
    UNION ALL
    SELECT 'SUP002', 'Supplier ABC'
    UNION ALL
    SELECT 'SUP003', 'Supplier XYZ'
    UNION ALL
    SELECT 'SUP002', 'Supplier ABC'
)

SELECT
    supplier_id,
    supplier_name,
    COUNT(*) AS record_count
FROM suppliers
GROUP BY supplier_id, supplier_name
HAVING COUNT(*) > 1;


-- ============================================================
-- 6. STANDARDIZE TEXT
-- Normalize supplier names.
-- ============================================================

WITH suppliers AS (
    SELECT '  Skoda Auto  ' AS supplier_name
    UNION ALL
    SELECT 'SUPPLIER ABC'
    UNION ALL
    SELECT '  supplier xyz'
    UNION ALL
    SELECT 'Supplier DEF  '
)

SELECT
    supplier_name,
    TRIM(
        UPPER(
            REPLACE(supplier_name, '  ', ' ')
        )
    ) AS standardized_supplier_name
FROM suppliers;


-- ============================================================
-- 7. VALIDATE COUNTRY CODES
-- Identify records with invalid country codes.
-- ============================================================

WITH suppliers AS (
    SELECT 'Supplier A' AS supplier_name, 'DE' AS country_code
    UNION ALL
    SELECT 'Supplier B', 'CZ'
    UNION ALL
    SELECT 'Supplier C', 'ES'
    UNION ALL
    SELECT 'Supplier D', 'XXX'
)

SELECT
    supplier_name,
    country_code,
    CASE
        WHEN country_code IN ('DE', 'CZ', 'ES', 'SK', 'AT', 'CH')
            THEN 'Valid'
        ELSE 'Invalid'
    END AS country_status
FROM suppliers;


-- ============================================================
-- 8. VALIDATE SUPPLIER IDs
-- Identify missing supplier IDs.
-- ============================================================

WITH suppliers AS (
    SELECT 'SUP001' AS supplier_id, 'Supplier A' AS supplier_name
    UNION ALL
    SELECT NULL, 'Supplier B'
    UNION ALL
    SELECT 'SUP003', 'Supplier C'
)

SELECT
    supplier_id,
    supplier_name,
    CASE
        WHEN supplier_id IS NULL THEN 'Missing Supplier ID'
        ELSE 'Valid'
    END AS supplier_id_status
FROM suppliers;


-- ============================================================
-- 9. VALIDATE DUNS NUMBERS
-- DUNS numbers normally contain nine digits.
--
-- This example checks whether the value contains
-- exactly nine characters.
-- ============================================================

WITH suppliers AS (
    SELECT 'Supplier A' AS supplier_name, '123456789' AS duns_number
    UNION ALL
    SELECT 'Supplier B', '12345'
    UNION ALL
    SELECT 'Supplier C', NULL
    UNION ALL
    SELECT 'Supplier D', '987654321'
)

SELECT
    supplier_name,
    duns_number,
    CASE
        WHEN duns_number IS NULL
            THEN 'Missing'
        WHEN LENGTH(duns_number) = 9
            THEN 'Valid'
        ELSE 'Invalid'
    END AS duns_status
FROM suppliers;


-- ============================================================
-- 10. SUPPLIER COMPLIANCE CHECK
-- Check whether suppliers have a valid S-Rating.
-- ============================================================

WITH suppliers AS (
    SELECT 'Supplier A' AS supplier_name, 85 AS s_rating
    UNION ALL
    SELECT 'Supplier B', 72
    UNION ALL
    SELECT 'Supplier C', NULL
    UNION ALL
    SELECT 'Supplier D', 45
)

SELECT
    supplier_name,
    s_rating,
    CASE
        WHEN s_rating IS NULL
            THEN 'Missing'
        WHEN s_rating >= 80
            THEN 'Compliant'
        WHEN s_rating >= 60
            THEN 'Review Required'
        ELSE 'High Risk'
    END AS compliance_status
FROM suppliers;


-- ============================================================
-- 11. SUPPLIER DATA QUALITY SCORE
-- Calculate how many mandatory fields are complete.
-- ============================================================

WITH suppliers AS (
    SELECT
        'Supplier A' AS supplier_name,
        '123456789' AS duns_number,
        'DE' AS country_code,
        85 AS s_rating

    UNION ALL

    SELECT
        'Supplier B',
        NULL,
        'CZ',
        72

    UNION ALL

    SELECT
        'Supplier C',
        '987654321',
        NULL,
        NULL
)

SELECT
    supplier_name,
    duns_number,
    country_code,
    s_rating,

    (
        CASE WHEN duns_number IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN country_code IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN s_rating IS NOT NULL THEN 1 ELSE 0 END
    ) AS completed_fields,

    CASE
        WHEN duns_number IS NOT NULL
         AND country_code IS NOT NULL
         AND s_rating IS NOT NULL
            THEN 'Complete'
        ELSE 'Incomplete'
    END AS data_quality_status

FROM suppliers;


-- ============================================================
-- 12. DATA COMPLETENESS PERCENTAGE
-- Calculate the percentage of completed mandatory fields.
-- ============================================================

WITH suppliers AS (
    SELECT
        'Supplier A' AS supplier_name,
        '123456789' AS duns_number,
        'DE' AS country_code,
        85 AS s_rating

    UNION ALL

    SELECT
        'Supplier B',
        NULL,
        'CZ',
        72

    UNION ALL

    SELECT
        'Supplier C',
        '987654321',
        NULL,
        NULL
)

SELECT
    supplier_name,

    ROUND(
        (
            CASE WHEN duns_number IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN country_code IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN s_rating IS NOT NULL THEN 1 ELSE 0 END
        ) * 100.0 / 3,
        2
    ) AS data_completeness_percentage

FROM suppliers;


-- ============================================================
-- 13. OVERALL SUPPLIER DATA QUALITY
-- Create a simple supplier master-data classification.
-- ============================================================

WITH suppliers AS (
    SELECT
        'Supplier A' AS supplier_name,
        '123456789' AS duns_number,
        'DE' AS country_code,
        85 AS s_rating

    UNION ALL

    SELECT
        'Supplier B',
        NULL,
        'CZ',
        72

    UNION ALL

    SELECT
        'Supplier C',
        '987654321',
        NULL,
        NULL

    UNION ALL

    SELECT
        'Supplier D',
        NULL,
        NULL,
        45
)

SELECT
    supplier_name,

    ROUND(
        (
            CASE WHEN duns_number IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN country_code IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN s_rating IS NOT NULL THEN 1 ELSE 0 END
        ) * 100.0 / 3,
        2
    ) AS completeness_percentage,

    CASE
        WHEN duns_number IS NULL
          OR country_code IS NULL
          OR s_rating IS NULL
            THEN 'Incomplete'
        ELSE 'Complete'
    END AS data_quality_status,

    CASE
        WHEN s_rating IS NULL
            THEN 'Compliance Data Missing'
        WHEN s_rating >= 80
            THEN 'Compliant'
        WHEN s_rating >= 60
            THEN 'Review Required'
        ELSE 'High Risk'
    END AS compliance_status

FROM suppliers;


-- ============================================================
-- 14. FINAL BUSINESS ANALYSIS
-- Identify suppliers requiring immediate attention.
--
-- A supplier requires attention when:
-- - mandatory data is incomplete
-- OR
-- - S-Rating is below 60.
-- ============================================================

WITH suppliers AS (
    SELECT
        'Supplier A' AS supplier_name,
        '123456789' AS duns_number,
        'DE' AS country_code,
        85 AS s_rating

    UNION ALL

    SELECT
        'Supplier B',
        NULL,
        'CZ',
        72

    UNION ALL

    SELECT
        'Supplier C',
        '987654321',
        NULL,
        NULL

    UNION ALL

    SELECT
        'Supplier D',
        NULL,
        NULL,
        45
)

SELECT
    supplier_name,
    duns_number,
    country_code,
    s_rating,

    CASE
        WHEN duns_number IS NULL
          OR country_code IS NULL
          OR s_rating IS NULL
          OR s_rating < 60
            THEN 'ACTION REQUIRED'
        ELSE 'OK'
    END AS supplier_action

FROM suppliers

ORDER BY
    supplier_action DESC;


-- ============================================================
-- END OF LESSON 12
-- ============================================================