# Supply Chain Supplier Compliance & Performance Analytics

End-to-end supply chain analytics project focused on **supplier performance, delivery reliability, compliance, ESG status and supplier risk management**.

The project combines **Python, Pandas, SQL and SQLite** to transform raw supplier and order data into management-ready KPIs, supplier risk classifications and performance rankings.

> **Note:** This project uses synthetic data created for portfolio and learning purposes. It is inspired by common supplier management and compliance processes in the automotive supply chain and does not contain confidential company data.

---

## Business Problem

Supply chain and procurement teams need a reliable way to identify suppliers that may create operational or compliance risks.

Supplier performance cannot be evaluated using only one metric. A supplier may have a strong sustainability rating but poor delivery performance, or good delivery performance while failing compliance requirements.

The objective of this project is therefore to combine multiple supplier dimensions into one analytical view:

- Supplier master data quality
- Order volume and value
- Delivery performance
- On-Time Delivery (OTD)
- Supplier S-Rating
- ESG status
- Compliance status
- Supplier risk classification
- Supplier performance score
- Supplier ranking

The final analytical dataset can be used as the foundation for a management dashboard in Power BI.

---

## Project Workflow

```text
Raw CSV Data
      ↓
Python Data Cleaning
      ↓
Clean CSV Data
      ↓
Python → SQLite Data Load
      ↓
SQL Data Verification
      ↓
SQL Supplier Performance Analysis
      ↓
Python Supplier KPI Analysis
      ↓
Management-Ready KPI Dataset
      ↓
Power BI Dashboard