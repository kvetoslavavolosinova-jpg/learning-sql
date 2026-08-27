-- ============================================================
-- VERIFY SUPPLY CHAIN DATABASE
-- ============================================================

SELECT 'suppliers' AS table_name, COUNT(*) AS row_count
FROM suppliers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'compliance', COUNT(*)
FROM compliance;