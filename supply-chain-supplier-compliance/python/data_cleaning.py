import pandas as pd
from pathlib import Path


# ============================================================
# SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
# Data Cleaning Pipeline
# ============================================================

# Project paths
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"


# ============================================================
# 1. LOAD RAW DATA
# ============================================================

suppliers = pd.read_csv(DATA_DIR / "suppliers_raw.csv")
orders = pd.read_csv(DATA_DIR / "orders_raw.csv")
compliance = pd.read_csv(DATA_DIR / "compliance_raw.csv")


print("=" * 60)
print("RAW DATA LOADED")
print("=" * 60)

print(f"Suppliers:   {len(suppliers)} rows")
print(f"Orders:      {len(orders)} rows")
print(f"Compliance:  {len(compliance)} rows")


# ============================================================
# 2. SUPPLIER DATA CLEANING
# ============================================================

# Remove leading/trailing spaces from supplier names
suppliers["supplier_name"] = (
    suppliers["supplier_name"]
    .str.strip()
)


# Standardize country codes
suppliers["country_code"] = (
    suppliers["country_code"]
    .str.strip()
    .str.upper()
)


# Convert DUNS to string
suppliers["duns_number"] = (
    suppliers["duns_number"]
    .astype("string")
    .str.strip()
)


# Convert S-Rating to numeric
suppliers["s_rating"] = pd.to_numeric(
    suppliers["s_rating"],
    errors="coerce"
)


# ============================================================
# 3. DUNS VALIDATION
# ============================================================

suppliers["duns_status"] = "Valid"

suppliers.loc[
    suppliers["duns_number"].isna(),
    "duns_status"
] = "Missing"

suppliers.loc[
    suppliers["duns_number"].notna()
    & (suppliers["duns_number"].str.len() != 9),
    "duns_status"
] = "Invalid"


# ============================================================
# 4. REGISTRATION QUALITY
# ============================================================

suppliers["registration_status"] = (
    suppliers["registration_status"]
    .str.strip()
    .str.title()
)


suppliers["registration_quality"] = "Complete"

suppliers.loc[
    suppliers["registration_status"] != "Complete",
    "registration_quality"
] = "Incomplete"


# ============================================================
# 5. S-RATING CLASSIFICATION
# ============================================================

suppliers["compliance_status"] = "Missing"

suppliers.loc[
    suppliers["s_rating"] >= 80,
    "compliance_status"
] = "Compliant"

suppliers.loc[
    (suppliers["s_rating"] >= 60)
    & (suppliers["s_rating"] < 80),
    "compliance_status"
] = "Review Required"

suppliers.loc[
    suppliers["s_rating"] < 60,
    "compliance_status"
] = "High Risk"


# ============================================================
# 6. DUPLICATE SUPPLIER DETECTION
# ============================================================

suppliers["duplicate_supplier"] = (
    suppliers["supplier_name"]
    .duplicated(keep=False)
)


# ============================================================
# 7. ORDER DATA CLEANING
# ============================================================

date_columns = [
    "order_date",
    "expected_delivery",
    "actual_delivery"
]

for column in date_columns:
    orders[column] = pd.to_datetime(
        orders[column],
        errors="coerce"
    )


orders["quantity"] = pd.to_numeric(
    orders["quantity"],
    errors="coerce"
)


orders["order_value"] = pd.to_numeric(
    orders["order_value"],
    errors="coerce"
)


# ============================================================
# 8. DELIVERY PERFORMANCE
# ============================================================

orders["delay_days"] = (
    orders["actual_delivery"]
    - orders["expected_delivery"]
).dt.days


orders["lead_time_days"] = (
    orders["actual_delivery"]
    - orders["order_date"]
).dt.days


orders["delivery_status"] = "On Time"

orders.loc[
    orders["delay_days"] > 0,
    "delivery_status"
] = "Delayed"


orders.loc[
    orders["delay_days"] > 3,
    "delivery_status"
] = "Significant Delay"


# ============================================================
# 9. COMPLIANCE DATA CLEANING
# ============================================================

compliance["assessment_date"] = pd.to_datetime(
    compliance["assessment_date"],
    errors="coerce"
)


compliance["esg_status"] = (
    compliance["esg_status"]
    .str.strip()
    .str.title()
)


compliance["code_of_conduct"] = (
    compliance["code_of_conduct"]
    .str.strip()
    .str.title()
)


compliance["compliance_status"] = (
    compliance["compliance_status"]
    .str.strip()
    .str.title()
)


# ============================================================
# 10. FINAL DATA QUALITY REPORT
# ============================================================

print()
print("=" * 60)
print("DATA QUALITY REPORT")
print("=" * 60)

print()
print("Missing DUNS:")
print(
    suppliers["duns_number"]
    .isna()
    .sum()
)

print()
print("Missing S-Rating:")
print(
    suppliers["s_rating"]
    .isna()
    .sum()
)

print()
print("Incomplete registrations:")
print(
    (suppliers["registration_quality"] == "Incomplete")
    .sum()
)

print()
print("Duplicate supplier names:")
print(
    suppliers["duplicate_supplier"]
    .sum()
)

print()
print("Delayed orders:")
print(
    (orders["delay_days"] > 0)
    .sum()
)

print()
print("Significantly delayed orders:")
print(
    (orders["delay_days"] > 3)
    .sum()
)


# ============================================================
# 11. EXPORT CLEAN DATA
# ============================================================

suppliers.to_csv(
    DATA_DIR / "suppliers_clean.csv",
    index=False
)

orders.to_csv(
    DATA_DIR / "orders_clean.csv",
    index=False
)

compliance.to_csv(
    DATA_DIR / "compliance_clean.csv",
    index=False
)


print()
print("=" * 60)
print("CLEAN DATA EXPORTED")
print("=" * 60)

print("suppliers_clean.csv")
print("orders_clean.csv")
print("compliance_clean.csv")