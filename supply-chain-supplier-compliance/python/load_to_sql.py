import sqlite3
import pandas as pd
from pathlib import Path


# ============================================================
# SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
# Load Clean CSV Data into SQLite
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"

DB_PATH = BASE_DIR.parent / "practice.db"


# ============================================================
# CONNECT TO DATABASE
# ============================================================

conn = sqlite3.connect(DB_PATH)


# ============================================================
# LOAD SUPPLIERS
# ============================================================

suppliers = pd.read_csv(
    DATA_DIR / "suppliers_clean.csv"
)

suppliers.to_sql(
    "suppliers",
    conn,
    if_exists="replace",
    index=False
)


# ============================================================
# LOAD ORDERS
# ============================================================

orders = pd.read_csv(
    DATA_DIR / "orders_clean.csv"
)

orders.to_sql(
    "orders",
    conn,
    if_exists="replace",
    index=False
)


# ============================================================
# LOAD COMPLIANCE
# ============================================================

compliance = pd.read_csv(
    DATA_DIR / "compliance_clean.csv"
)

compliance.to_sql(
    "compliance",
    conn,
    if_exists="replace",
    index=False
)


# ============================================================
# VERIFY DATA
# ============================================================

print("=" * 60)
print("SQL DATABASE CREATED")
print("=" * 60)

print(f"Suppliers loaded:   {len(suppliers)}")
print(f"Orders loaded:      {len(orders)}")
print(f"Compliance loaded:  {len(compliance)}")

print("=" * 60)


conn.close()