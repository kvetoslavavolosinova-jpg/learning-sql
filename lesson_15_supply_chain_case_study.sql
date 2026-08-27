-- ============================================================
-- LESSON 15: SUPPLY CHAIN SQL CASE STUDY
-- ============================================================
-- Project:
-- Supply Chain & Supplier Compliance Analytics
--
-- Business objective:
-- Analyze supplier compliance, data quality,
-- delivery performance and supplier risk.
--
-- SQL concepts used:
-- JOINs
-- CASE
-- CTEs
-- Window Functions
-- Aggregations
-- Date Functions
-- String Functions
-- Data Quality
-- Views
-- Business KPIs
--
-- Database: practice.db
-- ============================================================


-- ============================================================
-- 1. CREATE SUPPLIER DATASET
-- ============================================================

DROP TABLE IF EXISTS sc_suppliers;

CREATE TABLE sc_suppliers (
    supplier_id TEXT,
    supplier_name TEXT,
    country_code TEXT,
    duns_number TEXT,
    s_rating INTEGER
);


INSERT INTO sc_suppliers VALUES
('SUP001', '  Auto Parts GmbH  ', 'DE', '123456789', 92),
('SUP002', 'Supplier ABC s.r.o.', 'CZ', '234567891', 78),
('SUP003', 'Supplier XYZ S.L.', 'ES', NULL, 55),
('SUP004', 'Supplier DEF s.r.o.', 'SK', '456789123', NULL),
('SUP005', 'Supplier GHI GmbH', 'AT', '567891234', 88),
('SUP006', 'Supplier JKL AG', 'CH', '678912345', 63),
('SUP007', 'Supplier MNO GmbH', 'DE', NULL, 48),
('SUP008', 'Supplier PQR S.L.', 'ES', '789123456', 85);


-- ============================================================
-- 2. CREATE ORDERS DATASET
-- ============================================================

DROP TABLE IF EXISTS sc_orders;

CREATE TABLE sc_orders (
    order_id TEXT,
    supplier_id TEXT,
    order_date TEXT,
    expected_delivery TEXT,
    actual_delivery TEXT,
    quantity INTEGER,
    order_value REAL
);


INSERT INTO sc_orders VALUES
('ORD001', 'SUP001', '2026-01-05', '2026-01-12', '2026-01-12', 100, 15000),
('ORD002', 'SUP001', '2026-02-10', '2026-02-17', '2026-02-18', 120, 18000),
('ORD003', 'SUP002', '2026-01-08', '2026-01-15', '2026-01-17', 80, 12000),
('ORD004', 'SUP002', '2026-02-12', '2026-02-19', '2026-02-19', 90, 13500),
('ORD005', 'SUP003', '2026-01-10', '2026-01-20', '2026-01-28', 70, 9000),
('ORD006', 'SUP003', '2026-02-15', '2026-02-25', '2026-03-02', 65, 8500),
('ORD007', 'SUP004', '2026-01-12', '2026-01-19', '2026-01-19', 110, 14000),
('ORD008', 'SUP004', '2026-02-18', '2026-02-25', '2026-02-27', 100, 13000),
('ORD009', 'SUP005', '2026-01-15', '2026-01-22', '2026-01-21', 150, 25000),
('ORD010', 'SUP005', '2026-02-20', '2026-02-27', '2026-02-27', 160, 27000),
('ORD011', 'SUP006', '2026-01-18', '2026-01-25', '2026-01-30', 95, 16000),
('ORD012', 'SUP006', '2026-02-22', '2026-03-01', '2026-03-03', 90, 15000),
('ORD013', 'SUP007', '2026-01-20', '2026-01-27', '2026-02-05', 60, 8000),
('ORD014', 'SUP007', '2026-02-25', '2026-03-04', '2026-03-12', 55, 7500),
('ORD015', 'SUP008', '2026-01-22', '2026-01-29', '2026-01-29', 130, 22000),
('ORD016', 'SUP008', '2026-02-27', '2026-03-06', '2026-03-06', 140, 24000);


-- ============================================================
-- 3. INSPECT SUPPLIER DATA
-- ============================================================

SELECT
    *
FROM sc_suppliers;


-- ============================================================
-- 4. INSPECT ORDER DATA
-- ============================================================

SELECT
    *
FROM sc_orders;


-- ============================================================
-- 5. CLEAN SUPPLIER MASTER DATA
-- ============================================================

SELECT
    supplier_id,

    TRIM(supplier_name) AS supplier_name,

    country_code,

    duns_number,

    s_rating

FROM sc_suppliers;


-- ============================================================
-- 6. DUNS DATA QUALITY
-- ============================================================

SELECT
    supplier_id,
    supplier_name,
    duns_number,

    CASE
        WHEN duns_number IS NULL
            THEN 'Missing'
        WHEN LENGTH(duns_number) = 9
            THEN 'Valid'
        ELSE 'Invalid'
    END AS duns_status

FROM sc_suppliers;


-- ============================================================
-- 7. S-RATING COMPLIANCE
-- ============================================================

SELECT
    supplier_id,
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

FROM sc_suppliers;


-- ============================================================
-- 8. ORDER LEAD TIME
-- ============================================================

SELECT
    order_id,
    supplier_id,
    order_date,
    expected_delivery,
    actual_delivery,

    ROUND(
        JULIANDAY(actual_delivery)
        - JULIANDAY(order_date),
        2
    ) AS actual_lead_time_days

FROM sc_orders;


-- ============================================================
-- 9. DELIVERY DELAY
-- ============================================================

SELECT
    order_id,
    supplier_id,
    expected_delivery,
    actual_delivery,

    JULIANDAY(actual_delivery)
    - JULIANDAY(expected_delivery)
        AS delay_days

FROM sc_orders;


-- ============================================================
-- 10. DELIVERY PERFORMANCE
-- ============================================================

SELECT
    order_id,
    supplier_id,

    CASE
        WHEN JULIANDAY(actual_delivery)
             <= JULIANDAY(expected_delivery)
            THEN 'On Time'

        WHEN JULIANDAY(actual_delivery)
             - JULIANDAY(expected_delivery) <= 3
            THEN 'Minor Delay'

        ELSE 'Significant Delay'
    END AS delivery_status

FROM sc_orders;


-- ============================================================
-- 11. SUPPLIER + ORDERS
-- JOIN SUPPLIER MASTER DATA WITH ORDERS
-- ============================================================

SELECT
    o.order_id,
    TRIM(s.supplier_name) AS supplier_name,
    s.country_code,
    s.s_rating,
    o.order_date,
    o.expected_delivery,
    o.actual_delivery,
    o.quantity,
    o.order_value

FROM sc_orders o

JOIN sc_suppliers s
    ON o.supplier_id = s.supplier_id;


-- ============================================================
-- 12. SUPPLIER DELIVERY KPI
-- Calculate orders and on-time delivery rate.
-- ============================================================

SELECT
    s.supplier_id,
    TRIM(s.supplier_name) AS supplier_name,

    COUNT(o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN JULIANDAY(o.actual_delivery)
                 <= JULIANDAY(o.expected_delivery)
                THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    ROUND(
        SUM(
            CASE
                WHEN JULIANDAY(o.actual_delivery)
                     <= JULIANDAY(o.expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(o.order_id),
        2
    ) AS on_time_delivery_rate

FROM sc_suppliers s

LEFT JOIN sc_orders o
    ON s.supplier_id = o.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    on_time_delivery_rate DESC;


-- ============================================================
-- 13. SUPPLIER ORDER VALUE
-- ============================================================

SELECT
    s.supplier_id,
    TRIM(s.supplier_name) AS supplier_name,

    COUNT(o.order_id) AS total_orders,

    SUM(o.quantity) AS total_quantity,

    ROUND(
        SUM(o.order_value),
        2
    ) AS total_order_value

FROM sc_suppliers s

LEFT JOIN sc_orders o
    ON s.supplier_id = o.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY total_order_value DESC;


-- ============================================================
-- 14. SUPPLIER PERFORMANCE CTE
-- Combine compliance and delivery performance.
-- ============================================================

WITH delivery_stats AS (

    SELECT
        supplier_id,

        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN JULIANDAY(actual_delivery)
                     <= JULIANDAY(expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) AS on_time_orders

    FROM sc_orders

    GROUP BY supplier_id
)

SELECT
    s.supplier_id,
    TRIM(s.supplier_name) AS supplier_name,
    s.country_code,
    s.s_rating,

    CASE
        WHEN s.s_rating IS NULL
            THEN 'Missing'
        WHEN s.s_rating >= 80
            THEN 'Compliant'
        WHEN s.s_rating >= 60
            THEN 'Review Required'
        ELSE 'High Risk'
    END AS compliance_status,

    ds.total_orders,
    ds.on_time_orders,

    ROUND(
        ds.on_time_orders * 100.0
        / ds.total_orders,
        2
    ) AS on_time_delivery_rate

FROM sc_suppliers s

LEFT JOIN delivery_stats ds
    ON s.supplier_id = ds.supplier_id;


-- ============================================================
-- 15. SUPPLIER RISK CLASSIFICATION
-- ============================================================

WITH delivery_stats AS (

    SELECT
        supplier_id,

        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN JULIANDAY(actual_delivery)
                     <= JULIANDAY(expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) AS on_time_orders

    FROM sc_orders

    GROUP BY supplier_id
)

SELECT
    s.supplier_id,
    TRIM(s.supplier_name) AS supplier_name,
    s.s_rating,

    ROUND(
        ds.on_time_orders * 100.0
        / ds.total_orders,
        2
    ) AS on_time_delivery_rate,

    CASE
        WHEN s.s_rating IS NULL
            OR s.s_rating < 60
            OR ds.on_time_orders * 100.0
               / ds.total_orders < 80
            THEN 'HIGH RISK'

        WHEN s.s_rating < 80
            OR ds.on_time_orders * 100.0
               / ds.total_orders < 95
            THEN 'MEDIUM RISK'

        ELSE 'LOW RISK'
    END AS supplier_risk

FROM sc_suppliers s

JOIN delivery_stats ds
    ON s.supplier_id = ds.supplier_id

ORDER BY
    CASE supplier_risk
        WHEN 'HIGH RISK' THEN 1
        WHEN 'MEDIUM RISK' THEN 2
        ELSE 3
    END;


-- ============================================================
-- 16. WINDOW FUNCTION
-- Rank suppliers by order value.
-- ============================================================

WITH supplier_value AS (

    SELECT
        s.supplier_id,
        TRIM(s.supplier_name) AS supplier_name,

        SUM(o.order_value) AS total_order_value

    FROM sc_suppliers s

    JOIN sc_orders o
        ON s.supplier_id = o.supplier_id

    GROUP BY
        s.supplier_id,
        s.supplier_name
)

SELECT
    supplier_id,
    supplier_name,
    total_order_value,

    RANK() OVER (
        ORDER BY total_order_value DESC
    ) AS supplier_value_rank

FROM supplier_value;


-- ============================================================
-- 17. FINAL SUPPLIER SCORECARD
--
-- This is the main analytical query.
-- ============================================================

WITH delivery_stats AS (

    SELECT
        supplier_id,

        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN JULIANDAY(actual_delivery)
                     <= JULIANDAY(expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) AS on_time_orders,

        SUM(order_value) AS total_order_value,

        AVG(
            JULIANDAY(actual_delivery)
            - JULIANDAY(order_date)
        ) AS average_lead_time

    FROM sc_orders

    GROUP BY supplier_id
)

SELECT
    s.supplier_id,

    TRIM(s.supplier_name)
        AS supplier_name,

    s.country_code,

    s.duns_number,

    s.s_rating,

    CASE
        WHEN s.s_rating IS NULL
            THEN 'Missing'
        WHEN s.s_rating >= 80
            THEN 'Compliant'
        WHEN s.s_rating >= 60
            THEN 'Review Required'
        ELSE 'High Risk'
    END AS compliance_status,

    ds.total_orders,

    ds.on_time_orders,

    ROUND(
        ds.on_time_orders * 100.0
        / ds.total_orders,
        2
    ) AS on_time_delivery_rate,

    ROUND(
        ds.average_lead_time,
        2
    ) AS average_lead_time_days,

    ROUND(
        ds.total_order_value,
        2
    ) AS total_order_value,

    CASE
        WHEN s.duns_number IS NULL
            THEN 'Missing'

        WHEN LENGTH(s.duns_number) = 9
            THEN 'Valid'

        ELSE 'Invalid'
    END AS duns_status

FROM sc_suppliers s

LEFT JOIN delivery_stats ds
    ON s.supplier_id = ds.supplier_id

ORDER BY
    ds.total_order_value DESC;


-- ============================================================
-- 18. SUPPLIER ACTION LIST
-- Identify suppliers requiring management attention.
-- ============================================================

WITH delivery_stats AS (

    SELECT
        supplier_id,

        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN JULIANDAY(actual_delivery)
                     <= JULIANDAY(expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) AS on_time_orders

    FROM sc_orders

    GROUP BY supplier_id
)

SELECT
    s.supplier_id,
    TRIM(s.supplier_name) AS supplier_name,
    s.s_rating,
    s.duns_number,

    ROUND(
        ds.on_time_orders * 100.0
        / ds.total_orders,
        2
    ) AS on_time_delivery_rate,

    CASE
        WHEN s.s_rating IS NULL
            THEN 'Missing S-Rating'

        WHEN s.s_rating < 60
            THEN 'ESG Risk'

        WHEN s.duns_number IS NULL
            THEN 'Missing DUNS'

        WHEN ds.on_time_orders * 100.0
             / ds.total_orders < 80
            THEN 'Delivery Risk'

        ELSE 'No Immediate Action'
    END AS action_required

FROM sc_suppliers s

JOIN delivery_stats ds
    ON s.supplier_id = ds.supplier_id

WHERE
    s.s_rating IS NULL
    OR s.s_rating < 60
    OR s.duns_number IS NULL
    OR ds.on_time_orders * 100.0
       / ds.total_orders < 80

ORDER BY
    action_required;


-- ============================================================
-- 19. MANAGEMENT KPIs
-- ============================================================

WITH delivery_stats AS (

    SELECT
        supplier_id,

        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN JULIANDAY(actual_delivery)
                     <= JULIANDAY(expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) AS on_time_orders

    FROM sc_orders

    GROUP BY supplier_id
)

SELECT

    COUNT(*) AS total_suppliers,

    SUM(
        CASE
            WHEN s.s_rating >= 80
                THEN 1
            ELSE 0
        END
    ) AS compliant_suppliers,

    ROUND(
        SUM(
            CASE
                WHEN s.s_rating >= 80
                    THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS compliance_rate,

    ROUND(
        SUM(ds.on_time_orders) * 100.0
        / SUM(ds.total_orders),
        2
    ) AS overall_on_time_delivery_rate,

    ROUND(
        AVG(s.s_rating),
        2
    ) AS average_s_rating,

    SUM(ds.total_orders)
        AS total_orders

FROM sc_suppliers s

JOIN delivery_stats ds
    ON s.supplier_id = ds.supplier_id;


-- ============================================================
-- 20. FINAL MANAGEMENT VIEW
-- ============================================================

DROP VIEW IF EXISTS supplier_scorecard;

CREATE VIEW supplier_scorecard AS

WITH delivery_stats AS (

    SELECT
        supplier_id,

        COUNT(*) AS total_orders,

        SUM(
            CASE
                WHEN JULIANDAY(actual_delivery)
                     <= JULIANDAY(expected_delivery)
                    THEN 1
                ELSE 0
            END
        ) AS on_time_orders,

        SUM(order_value) AS total_order_value,

        AVG(
            JULIANDAY(actual_delivery)
            - JULIANDAY(order_date)
        ) AS average_lead_time

    FROM sc_orders

    GROUP BY supplier_id
)

SELECT

    s.supplier_id,

    TRIM(s.supplier_name)
        AS supplier_name,

    s.country_code,

    s.duns_number,

    s.s_rating,

    CASE
        WHEN s.s_rating IS NULL
            THEN 'Missing'
        WHEN s.s_rating >= 80
            THEN 'Compliant'
        WHEN s.s_rating >= 60
            THEN 'Review Required'
        ELSE 'High Risk'
    END AS compliance_status,

    ds.total_orders,

    ROUND(
        ds.on_time_orders * 100.0
        / ds.total_orders,
        2
    ) AS on_time_delivery_rate,

    ROUND(
        ds.average_lead_time,
        2
    ) AS average_lead_time_days,

    ROUND(
        ds.total_order_value,
        2
    ) AS total_order_value,

    CASE
        WHEN s.s_rating IS NULL
          OR s.s_rating < 60
          OR s.duns_number IS NULL
          OR ds.on_time_orders * 100.0
             / ds.total_orders < 80
            THEN 'HIGH RISK'

        WHEN s.s_rating < 80
          OR ds.on_time_orders * 100.0
             / ds.total_orders < 95
            THEN 'MEDIUM RISK'

        ELSE 'LOW RISK'
    END AS supplier_risk

FROM sc_suppliers s

LEFT JOIN delivery_stats ds
    ON s.supplier_id = ds.supplier_id;


-- ============================================================
-- 21. QUERY FINAL MANAGEMENT VIEW
-- ============================================================

SELECT
    *
FROM supplier_scorecard

ORDER BY
    CASE supplier_risk
        WHEN 'HIGH RISK' THEN 1
        WHEN 'MEDIUM RISK' THEN 2
        ELSE 3
    END,
    on_time_delivery_rate ASC;


-- ============================================================
-- 22. FINAL HIGH-RISK SUPPLIER REPORT
-- ============================================================

SELECT
    supplier_id,
    supplier_name,
    country_code,
    s_rating,
    compliance_status,
    on_time_delivery_rate,
    average_lead_time_days,
    total_order_value,
    supplier_risk

FROM supplier_scorecard

WHERE supplier_risk = 'HIGH RISK'

ORDER BY
    on_time_delivery_rate ASC;


-- ============================================================
-- END OF LESSON 15
-- ============================================================