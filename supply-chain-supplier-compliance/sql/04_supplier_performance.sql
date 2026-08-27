-- ============================================================
-- SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
-- Lesson 04: Supplier Performance Analysis
-- ============================================================
--
-- Objective:
-- Analyze supplier performance using:
--   - Supplier master data
--   - Order performance
--   - Sustainability and compliance data
--
-- ============================================================


-- ============================================================
-- QUERY 1
-- Supplier order overview
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value
FROM suppliers AS s
LEFT JOIN orders AS o
    ON s.supplier_id = o.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY
    total_order_value DESC;


-- ============================================================
-- QUERY 2
-- Supplier delivery performance
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN o.delivery_status = 'On Time'
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN o.delivery_status = 'Delayed'
            THEN 1
            ELSE 0
        END
    ) AS delayed_orders

FROM suppliers AS s

LEFT JOIN orders AS o
    ON s.supplier_id = o.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    delayed_orders DESC;


-- ============================================================
-- QUERY 3
-- On-time delivery rate
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(o.order_id) AS total_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.delivery_status = 'On Time'
                THEN 1
                ELSE 0
            END
        )
        / COUNT(o.order_id),
        2
    ) AS on_time_delivery_rate

FROM suppliers AS s

LEFT JOIN orders AS o
    ON s.supplier_id = o.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name

ORDER BY
    on_time_delivery_rate ASC;


-- ============================================================
-- QUERY 4
-- Supplier compliance overview
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    c.s_rating,
    c.esg_status,
    c.code_of_conduct,
    c.compliance_status,
    c.assessment_date

FROM suppliers AS s

LEFT JOIN compliance AS c
    ON s.supplier_id = c.supplier_id

ORDER BY
    c.s_rating ASC;


-- ============================================================
-- QUERY 5
-- Combined Supplier Scorecard
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,

    COUNT(o.order_id) AS total_orders,

    ROUND(
        SUM(o.order_value),
        2
    ) AS total_order_value,

    SUM(
        CASE
            WHEN o.delivery_status = 'Delayed'
            THEN 1
            ELSE 0
        END
    ) AS delayed_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.delivery_status = 'On Time'
                THEN 1
                ELSE 0
            END
        )
        / COUNT(o.order_id),
        2
    ) AS on_time_delivery_rate,

    c.s_rating,
    c.esg_status,
    c.code_of_conduct,
    c.compliance_status

FROM suppliers AS s

LEFT JOIN orders AS o
    ON s.supplier_id = o.supplier_id

LEFT JOIN compliance AS c
    ON s.supplier_id = c.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    c.s_rating,
    c.esg_status,
    c.code_of_conduct,
    c.compliance_status

ORDER BY
    on_time_delivery_rate ASC;


-- ============================================================
-- QUERY 6
-- Supplier Risk Classification
-- ============================================================
--
-- HIGH RISK:
--   S-Rating < 70
--   OR On-time delivery < 70%
--   OR ESG status is not Compliant
--   OR Compliance status is not Complete
--
-- MEDIUM RISK:
--   S-Rating < 85
--   OR On-time delivery < 90%
--
-- LOW RISK:
--   Everything else
--
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,

    c.s_rating,
    c.esg_status,
    c.compliance_status,

    COUNT(o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN o.delivery_status = 'Delayed'
            THEN 1
            ELSE 0
        END
    ) AS delayed_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.delivery_status = 'On Time'
                THEN 1
                ELSE 0
            END
        )
        / COUNT(o.order_id),
        2
    ) AS on_time_delivery_rate,

    CASE

        WHEN c.s_rating < 70
             OR c.esg_status != 'Compliant'
             OR c.compliance_status != 'Complete'
             OR (
                 100.0 *
                 SUM(
                     CASE
                         WHEN o.delivery_status = 'On Time'
                         THEN 1
                         ELSE 0
                     END
                 )
                 / COUNT(o.order_id)
             ) < 70
        THEN 'High Risk'

        WHEN c.s_rating < 85
             OR (
                 100.0 *
                 SUM(
                     CASE
                         WHEN o.delivery_status = 'On Time'
                         THEN 1
                         ELSE 0
                     END
                 )
                 / COUNT(o.order_id)
             ) < 90
        THEN 'Medium Risk'

        ELSE 'Low Risk'

    END AS supplier_risk

FROM suppliers AS s

LEFT JOIN orders AS o
    ON s.supplier_id = o.supplier_id

LEFT JOIN compliance AS c
    ON s.supplier_id = c.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    c.s_rating,
    c.esg_status,
    c.compliance_status

ORDER BY
    supplier_risk,
    on_time_delivery_rate ASC;


-- ============================================================
-- QUERY 7
-- Suppliers Requiring Management Attention
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,

    c.s_rating,
    c.esg_status,
    c.compliance_status,

    COUNT(o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN o.delivery_status = 'Delayed'
            THEN 1
            ELSE 0
        END
    ) AS delayed_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.delivery_status = 'On Time'
                THEN 1
                ELSE 0
            END
        )
        / COUNT(o.order_id),
        2
    ) AS on_time_delivery_rate

FROM suppliers AS s

LEFT JOIN orders AS o
    ON s.supplier_id = o.supplier_id

LEFT JOIN compliance AS c
    ON s.supplier_id = c.supplier_id

GROUP BY
    s.supplier_id,
    s.supplier_name,
    c.s_rating,
    c.esg_status,
    c.compliance_status

HAVING
    c.s_rating < 70
    OR c.esg_status != 'Compliant'
    OR c.compliance_status != 'Complete'
    OR (
        100.0 *
        SUM(
            CASE
                WHEN o.delivery_status = 'On Time'
                THEN 1
                ELSE 0
            END
        )
        / COUNT(o.order_id)
    ) < 70

ORDER BY
    delayed_orders DESC;


-- ============================================================
-- END OF LESSON 04
-- ============================================================