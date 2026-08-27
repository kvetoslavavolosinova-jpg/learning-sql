-- ============================================================
-- LESSON 11: STRING FUNCTIONS
-- ============================================================
-- Topics:
-- 1. LENGTH()
-- 2. UPPER()
-- 3. LOWER()
-- 4. TRIM()
-- 5. LTRIM()
-- 6. RTRIM()
-- 7. SUBSTR()
-- 8. REPLACE()
-- 9. INSTR()
-- 10. Combining string functions
-- 11. Data cleaning
-- 12. Business analysis
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. LENGTH()
-- Calculate the number of characters in a string.
-- ============================================================

SELECT
    name,
    LENGTH(name) AS name_length
FROM employees;


-- ============================================================
-- 2. UPPER()
-- Convert text to uppercase.
-- ============================================================

SELECT
    name,
    UPPER(name) AS uppercase_name
FROM employees;


-- ============================================================
-- 3. LOWER()
-- Convert text to lowercase.
-- ============================================================

SELECT
    name,
    LOWER(name) AS lowercase_name
FROM employees;


-- ============================================================
-- 4. TRIM()
-- Remove spaces from the beginning and end of a string.
-- ============================================================

SELECT
    TRIM('   Supplier ABC   ') AS cleaned_supplier;


-- ============================================================
-- 5. LTRIM()
-- Remove spaces from the left side.
-- ============================================================

SELECT
    LTRIM('   Supplier ABC') AS cleaned_supplier;


-- ============================================================
-- 6. RTRIM()
-- Remove spaces from the right side.
-- ============================================================

SELECT
    RTRIM('Supplier ABC   ') AS cleaned_supplier;


-- ============================================================
-- 7. SUBSTR()
-- Extract part of a string.
-- ============================================================

SELECT
    SUBSTR('SUPPLIER-2026-001', 1, 8) AS supplier_code;


-- ============================================================
-- 8. REPLACE()
-- Replace part of a string with another value.
-- ============================================================

SELECT
    REPLACE(
        'Supplier - Germany',
        'Germany',
        'DE'
    ) AS supplier_region;


-- ============================================================
-- 9. INSTR()
-- Find the position of a substring.
-- ============================================================

SELECT
    INSTR(
        'supplier@example.com',
        '@'
    ) AS at_position;


-- ============================================================
-- 10. COMBINE STRING FUNCTIONS
-- Remove spaces and standardize text.
-- ============================================================

SELECT
    TRIM(
        UPPER('   supplier abc   ')
    ) AS standardized_supplier;


-- ============================================================
-- 11. NORMALIZE COMPANY NAMES
-- Demonstrate basic supplier-name standardization.
-- ============================================================

WITH suppliers AS (
    SELECT '  Skoda Auto  ' AS supplier_name

    UNION ALL

    SELECT 'SKODA AUTO'

    UNION ALL

    SELECT 'skoda auto '

    UNION ALL

    SELECT '  Skoda  Auto'
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
-- 12. CLEAN MULTIPLE SPACES
-- Standardize supplier names with repeated spaces.
-- ============================================================

SELECT
    'Skoda  Auto  Supplier' AS original_name,
    REPLACE(
        REPLACE(
            TRIM('Skoda  Auto  Supplier'),
            '  ',
            ' '
        ),
        '  ',
        ' '
    ) AS cleaned_name;


-- ============================================================
-- 13. EXTRACT SUPPLIER CODE
-- Extract the first eight characters from a supplier identifier.
-- ============================================================

WITH suppliers AS (
    SELECT 'SUPP-001-DE' AS supplier_code
    UNION ALL
    SELECT 'SUPP-002-CZ'
    UNION ALL
    SELECT 'SUPP-003-ES'
)

SELECT
    supplier_code,
    SUBSTR(supplier_code, 1, 8) AS supplier_prefix
FROM suppliers;


-- ============================================================
-- 14. COUNTRY CODE
-- Extract the final two characters from a supplier code.
-- ============================================================

WITH suppliers AS (
    SELECT 'SUPP-001-DE' AS supplier_code
    UNION ALL
    SELECT 'SUPP-002-CZ'
    UNION ALL
    SELECT 'SUPP-003-ES'
)

SELECT
    supplier_code,
    SUBSTR(supplier_code, -2) AS country_code
FROM suppliers;


-- ============================================================
-- 15. EMAIL DOMAIN
-- Extract the domain from an email address.
-- ============================================================

WITH contacts AS (
    SELECT 'supplier@company.de' AS email
    UNION ALL
    SELECT 'procurement@company.cz'
    UNION ALL
    SELECT 'contact@supplier.es'
)

SELECT
    email,
    SUBSTR(
        email,
        INSTR(email, '@') + 1
    ) AS email_domain
FROM contacts;


-- ============================================================
-- 16. DATA QUALITY CHECK
-- Identify names that contain leading or trailing spaces.
-- ============================================================

WITH suppliers AS (
    SELECT 'Skoda Auto' AS supplier_name
    UNION ALL
    SELECT '  Supplier ABC'
    UNION ALL
    SELECT 'Supplier XYZ  '
    UNION ALL
    SELECT 'Clean Supplier'
)

SELECT
    supplier_name,
    CASE
        WHEN supplier_name != TRIM(supplier_name)
            THEN 'Needs Cleaning'
        ELSE 'Clean'
    END AS data_quality_status
FROM suppliers;


-- ============================================================
-- 17. STANDARDIZE SUPPLIER NAMES
-- Create a normalized supplier name and a quality status.
-- ============================================================

WITH suppliers AS (
    SELECT '  Skoda Auto  ' AS supplier_name
    UNION ALL
    SELECT 'SUPPLIER ABC'
    UNION ALL
    SELECT '  supplier xyz'
    UNION ALL
    SELECT 'Clean Supplier'
)

SELECT
    supplier_name,

    TRIM(
        UPPER(
            REPLACE(supplier_name, '  ', ' ')
        )
    ) AS standardized_supplier_name,

    CASE
        WHEN supplier_name != TRIM(supplier_name)
            THEN 'Needs Cleaning'
        ELSE 'Clean'
    END AS data_quality_status

FROM suppliers;


-- ============================================================
-- 18. BUSINESS ANALYSIS
-- Create a simple supplier master-data quality report.
-- ============================================================

WITH suppliers AS (
    SELECT '  Skoda Auto  ' AS supplier_name
    UNION ALL
    SELECT 'Supplier ABC'
    UNION ALL
    SELECT '  Supplier XYZ'
    UNION ALL
    SELECT 'Supplier DEF  '
)

SELECT
    supplier_name,

    TRIM(
        UPPER(
            REPLACE(supplier_name, '  ', ' ')
        )
    ) AS standardized_supplier_name,

    LENGTH(TRIM(supplier_name)) AS name_length,

    CASE
        WHEN supplier_name != TRIM(supplier_name)
            THEN 'Needs Cleaning'
        ELSE 'Clean'
    END AS data_quality_status

FROM suppliers

ORDER BY data_quality_status DESC;


-- ============================================================
-- END OF LESSON 11
-- ============================================================