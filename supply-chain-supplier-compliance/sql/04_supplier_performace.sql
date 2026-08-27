-- ============================================================
-- SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
-- Lesson 04: Supplier Performance Analysis
-- ============================================================
--
-- Objective:
-- Analyze supplier performance by combining:
--   1. Supplier master data
--   2. Order performance
--   3. Sustainability / compliance data
--
-- Business questions:
--   - How much business do we have with each supplier?
--   - How many orders were delayed?
--   - What is the on-time delivery rate?
--   - What is each supplier's S-Rating?
--   - Which suppliers represent the highest operational risk?
--
-- ============================================================


-- ============================================================
-- QUERY 1
-- Basic supplier + order overview
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_value) AS total_order_value
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
-- Supplier sustainability / compliance overview
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,
    c.s_rating,
    c.esg_status,
    c.registration_status

FROM suppliers AS s

LEFT JOIN compliance AS c
    ON s.supplier_id = c.supplier_id

ORDER BY
    c.s_rating ASC;


-- ============================================================
-- QUERY 5
-- Combined supplier performance scorecard
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,

    -- Order KPIs
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

    -- Compliance KPIs
    c.s_rating,
    c.esg_status,
    c.registration_status

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
    c.registration_status

ORDER BY
    on_time_delivery_rate ASC;


-- ============================================================
-- QUERY 6
-- Identify high-risk suppliers
-- ============================================================
--
-- Risk criteria:
--
--   HIGH RISK if:
--     S-Rating < 70
--     OR on-time delivery rate < 70%
--     OR ESG status is not Compliant
--     OR registration is not Complete
--
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,

    c.s_rating,
    c.esg_status,
    c.registration_status,

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
    ) AS on_time_delivery_rate,

    CASE
        WHEN c.s_rating < 70
             OR c.esg_status != 'Compliant'
             OR c.registration_status != 'Complete'
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
    c.registration_status

ORDER BY
    supplier_risk,
    on_time_delivery_rate ASC;


-- ============================================================
-- QUERY 7
-- Suppliers requiring immediate management attention
-- ============================================================

SELECT
    s.supplier_id,
    s.supplier_name,

    c.s_rating,
    c.esg_status,
    c.registration_status,

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
    c.registration_status

HAVING
    c.s_rating < 70
    OR c.esg_status != 'Compliant'
    OR c.registration_status != 'Complete'
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