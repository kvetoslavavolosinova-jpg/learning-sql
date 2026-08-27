-- ============================================================
-- SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
-- SQL Database Schema
-- ============================================================

-- ============================================================
-- 1. SUPPLIERS TABLE
-- ============================================================

DROP TABLE IF EXISTS suppliers;

CREATE TABLE suppliers (
    supplier_id TEXT PRIMARY KEY,
    supplier_name TEXT,
    country_code TEXT,
    duns_number TEXT,
    registration_status TEXT,
    s_rating REAL,
    duns_status TEXT,
    registration_quality TEXT,
    compliance_status TEXT,
    duplicate_supplier INTEGER
);


-- ============================================================
-- 2. ORDERS TABLE
-- ============================================================

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    supplier_id TEXT,
    order_date TEXT,
    expected_delivery TEXT,
    actual_delivery TEXT,
    quantity INTEGER,
    order_value REAL,
    delay_days INTEGER,
    lead_time_days INTEGER,
    delivery_status TEXT,

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);


-- ============================================================
-- 3. COMPLIANCE TABLE
-- ============================================================

DROP TABLE IF EXISTS compliance;

CREATE TABLE compliance (
    supplier_id TEXT PRIMARY KEY,
    s_rating REAL,
    esg_status TEXT,
    code_of_conduct TEXT,
    assessment_date TEXT,
    compliance_status TEXT,

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);


-- ============================================================
-- 4. SUPPLIER KPI TABLE
-- ============================================================

DROP TABLE IF EXISTS supplier_kpis;

CREATE TABLE supplier_kpis (
    supplier_id TEXT PRIMARY KEY,
    total_orders INTEGER,
    total_quantity INTEGER,
    total_order_value REAL,
    average_lead_time_days REAL,
    average_delay_days REAL,
    on_time_delivery_rate REAL,
    compliance_risk TEXT,
    delivery_risk TEXT,
    master_data_risk TEXT,
    supplier_risk TEXT,
    performance_score REAL,
    supplier_rank INTEGER,

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);


-- ============================================================
-- SCHEMA CREATED
-- ============================================================