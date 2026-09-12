-- ============================================================
-- SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
-- Lesson 05: Management Dashboard Dataset
-- ============================================================
--
-- Objective:
-- Create one clean supplier-level dataset for Power BI.
--
-- The dataset combines:
--   - Supplier master data
--   - Order performance
--   - Delivery performance
--   - ESG compliance
--   - S-Rating
--   - Supplier risk
--   - Performance score
--   - Supplier ranking
--
-- This query will become the main SQL data source
-- for the Supplier Scorecard Dashboard.
-- ============================================================


WITH supplier_performance AS (

    SELECT
        s.supplier_id,
        s.supplier_name,

        c.s_rating,
        c.esg_status,
        c.code_of_conduct,
        c.compliance_status,

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

        SUM(
            CASE
                WHEN o.delivery_status = 'On Time'
                THEN 1
                ELSE 0
            END
        ) AS on_time_orders,

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
        c.code_of_conduct,
        c.compliance_status
),


supplier_scored AS (

    SELECT
        *,

        -- ----------------------------------------------------
        -- Supplier Risk Classification
        -- ----------------------------------------------------

        CASE

            WHEN
                COALESCE(s_rating, 0) < 70
                OR COALESCE(on_time_delivery_rate, 0) < 70
                OR esg_status != 'Compliant'
                OR compliance_status != 'Compliant'

            THEN 'High Risk'


            WHEN
                COALESCE(s_rating, 0) < 85
                OR COALESCE(on_time_delivery_rate, 0) < 90

            THEN 'Medium Risk'


            ELSE 'Low Risk'

        END AS supplier_risk,


        -- ----------------------------------------------------
        -- Performance Score
        --
        -- 50% delivery performance
        -- 50% sustainability performance
        -- ----------------------------------------------------

        ROUND(
            (
                COALESCE(on_time_delivery_rate, 0) * 0.5
                +
                COALESCE(s_rating, 0) * 0.5
            ),
            2
        ) AS performance_score

    FROM supplier_performance
)


SELECT
    supplier_id,
    supplier_name,

    s_rating,

    esg_status,
    code_of_conduct,
    compliance_status,

    total_orders,
    total_order_value,

    on_time_orders,
    delayed_orders,
    on_time_delivery_rate,

    supplier_risk,
    performance_score,

    RANK() OVER (
        ORDER BY performance_score DESC
    ) AS supplier_rank

FROM supplier_scored

ORDER BY
    performance_score DESC;