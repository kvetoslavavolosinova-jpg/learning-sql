import pandas as pd
from pathlib import Path


# ============================================================
# SUPPLY CHAIN & SUPPLIER COMPLIANCE ANALYTICS
# Supplier Performance Analysis
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"


# ============================================================
# 1. LOAD CLEAN DATA
# ============================================================

suppliers = pd.read_csv(
    DATA_DIR / "suppliers_clean.csv"
)

orders = pd.read_csv(
    DATA_DIR / "orders_clean.csv"
)

compliance = pd.read_csv(
    DATA_DIR / "compliance_clean.csv"
)


# ============================================================
# 2. SUPPLIER DELIVERY KPIs
# ============================================================

supplier_orders = (
    orders
    .groupby("supplier_id")
    .agg(
        total_orders=("order_id", "count"),
        total_quantity=("quantity", "sum"),
        total_order_value=("order_value", "sum"),
        average_lead_time_days=("lead_time_days", "mean"),
        average_delay_days=("delay_days", "mean")
    )
    .reset_index()
)


# ============================================================
# 3. ON-TIME DELIVERY RATE
# ============================================================

on_time = (
    orders
    .assign(
        on_time=orders["delay_days"] <= 0
    )
    .groupby("supplier_id")
    ["on_time"]
    .mean()
    .reset_index()
)


on_time["on_time_delivery_rate"] = (
    on_time["on_time"] * 100
)


on_time = on_time.drop(
    columns=["on_time"]
)


# ============================================================
# 4. MERGE DELIVERY KPIs WITH SUPPLIER DATA
# ============================================================

supplier_kpis = suppliers.merge(
    supplier_orders,
    on="supplier_id",
    how="left"
)


supplier_kpis = supplier_kpis.merge(
    on_time,
    on="supplier_id",
    how="left"
)


# ============================================================
# 5. COMPLIANCE RISK
# ============================================================

supplier_kpis["compliance_risk"] = "Low Risk"


supplier_kpis.loc[
    supplier_kpis["s_rating"].isna(),
    "compliance_risk"
] = "High Risk"


supplier_kpis.loc[
    supplier_kpis["s_rating"] < 60,
    "compliance_risk"
] = "High Risk"


supplier_kpis.loc[
    (supplier_kpis["s_rating"] >= 60)
    & (supplier_kpis["s_rating"] < 80),
    "compliance_risk"
] = "Medium Risk"


# ============================================================
# 6. DELIVERY RISK
# ============================================================

supplier_kpis["delivery_risk"] = "Low Risk"


supplier_kpis.loc[
    supplier_kpis["on_time_delivery_rate"] < 80,
    "delivery_risk"
] = "High Risk"


supplier_kpis.loc[
    (supplier_kpis["on_time_delivery_rate"] >= 80)
    & (supplier_kpis["on_time_delivery_rate"] < 95),
    "delivery_risk"
] = "Medium Risk"


# ============================================================
# 7. MASTER DATA RISK
# ============================================================

supplier_kpis["master_data_risk"] = "Low Risk"


supplier_kpis.loc[
    supplier_kpis["duns_status"] != "Valid",
    "master_data_risk"
] = "High Risk"


supplier_kpis.loc[
    supplier_kpis["registration_quality"] == "Incomplete",
    "master_data_risk"
] = "High Risk"


# ============================================================
# 8. OVERALL SUPPLIER RISK
# ============================================================

supplier_kpis["supplier_risk"] = "Low Risk"


# High Risk:
# Critical compliance issue OR very poor delivery performance

supplier_kpis.loc[
    (
        (supplier_kpis["compliance_risk"] == "High Risk")
        |
        (supplier_kpis["delivery_risk"] == "High Risk")
    ),
    "supplier_risk"
] = "High Risk"


# Medium Risk:
# Moderate compliance/delivery issue OR master-data issue

supplier_kpis.loc[
    (
        (supplier_kpis["supplier_risk"] == "Low Risk")
        &
        (
            (supplier_kpis["compliance_risk"] == "Medium Risk")
            |
            (supplier_kpis["delivery_risk"] == "Medium Risk")
            |
            (supplier_kpis["master_data_risk"] == "High Risk")
        )
    ),
    "supplier_risk"
] = "Medium Risk"


# ============================================================
# 9. SUPPLIER PERFORMANCE SCORE
# ============================================================

supplier_kpis["performance_score"] = (
    supplier_kpis["s_rating"].fillna(0) * 0.5
    +
    supplier_kpis["on_time_delivery_rate"].fillna(0) * 0.5
)


supplier_kpis["performance_score"] = (
    supplier_kpis["performance_score"]
    .round(2)
)


# ============================================================
# 10. SUPPLIER RANKING
# ============================================================

supplier_kpis["supplier_rank"] = (
    supplier_kpis["performance_score"]
    .rank(
        ascending=False,
        method="dense"
    )
    .astype(int)
)


# ============================================================
# 11. SORT BY RISK AND PERFORMANCE
# ============================================================

risk_order = {
    "High Risk": 1,
    "Medium Risk": 2,
    "Low Risk": 3
}


supplier_kpis["risk_order"] = (
    supplier_kpis["supplier_risk"]
    .map(risk_order)
)


supplier_kpis = supplier_kpis.sort_values(
    by=[
        "risk_order",
        "performance_score"
    ],
    ascending=[
        True,
        True
    ]
)


supplier_kpis = supplier_kpis.drop(
    columns=["risk_order"]
)


# ============================================================
# 12. MANAGEMENT SUMMARY
# ============================================================

print("=" * 60)
print("SUPPLIER PERFORMANCE ANALYSIS")
print("=" * 60)

print()

print(
    f"Total suppliers: "
    f"{len(supplier_kpis)}"
)

print(
    f"Total orders: "
    f"{len(orders)}"
)

print(
    f"Total order value: "
    f"€{orders['order_value'].sum():,.2f}"
)

print(
    f"Average S-Rating: "
    f"{suppliers['s_rating'].mean():.2f}"
)

print(
    f"Overall on-time delivery rate: "
    f"{(orders['delay_days'] <= 0).mean() * 100:.2f}%"
)


# ============================================================
# 13. RISK SUMMARY
# ============================================================

print()
print("=" * 60)
print("SUPPLIER RISK SUMMARY")
print("=" * 60)

print(
    supplier_kpis["supplier_risk"]
    .value_counts()
)


# ============================================================
# 14. HIGH-RISK SUPPLIERS
# ============================================================

print()
print("=" * 60)
print("HIGH-RISK SUPPLIERS")
print("=" * 60)

high_risk = supplier_kpis[
    supplier_kpis["supplier_risk"] == "High Risk"
][
    [
        "supplier_id",
        "supplier_name",
        "s_rating",
        "on_time_delivery_rate",
        "supplier_risk"
    ]
]


print(
    high_risk.to_string(
        index=False
    )
)


# ============================================================
# 15. TOP SUPPLIERS
# ============================================================

print()
print("=" * 60)
print("TOP SUPPLIERS")
print("=" * 60)

top_suppliers = supplier_kpis.sort_values(
    by="performance_score",
    ascending=False
).head(5)


print(
    top_suppliers[
        [
            "supplier_id",
            "supplier_name",
            "performance_score",
            "supplier_rank"
        ]
    ].to_string(
        index=False
    )
)


# ============================================================
# 16. EXPORT FINAL ANALYTICAL DATASET
# ============================================================

supplier_kpis.to_csv(
    DATA_DIR / "supplier_kpi_analysis.csv",
    index=False
)


print()
print("=" * 60)
print("ANALYSIS COMPLETE")
print("=" * 60)

print(
    "Created: data/supplier_kpi_analysis.csv"
)