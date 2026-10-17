# Vrinda Store Analysis Report 2022
### End-to-End Data Analytics Project | Excel · SQL · Python · Power BI

An end-to-end retail sales analytics project analyzing Vrinda Store's 2022 sales data using Microsoft Excel, MySQL, Python, and Power BI. The project combines business analysis, data-quality validation, cross-tool metric reconciliation, and interactive dashboard reporting.

## Project Overview

The objective of this project is to analyze retail sales performance, understand revenue contribution across customer segments and sales channels, identify monthly trends, and build a consolidated view of business performance.

The workflow covers four stages:

1. **Excel:** Initial sales analysis and dashboard reporting.
2. **SQL:** Business queries, transaction classification, and channel-category revenue ranking.
3. **Python:** MySQL data extraction, data-quality checks, exploratory analysis, and metric reconciliation.
4. **Power BI:** Interactive KPI dashboard, date-table analysis, DAX measures, and detailed report pages.

## Business Questions

This project addresses the following business questions:

1. What are the total records, revenue, unique orders, and unique customers?
2. How is revenue distributed across customer gender?
3. Which sales channels contribute the most revenue?
4. What are the monthly revenue trends?
5. Which product category generates the highest revenue within each sales channel?
6. How do order status and transaction amounts behave under the defined financial classification rules?
7. Are selected revenue and record-count metrics consistent across Excel, SQL, Python, and Power BI?
8. Do the inspected records contain missing values, full-row duplicates, non-positive quantities, or negative amounts?

## Tools and Technologies

| Technology | Application |
|---|---|
| Microsoft Excel | Initial analysis and sales dashboard |
| MySQL | Data querying and business analysis |
| SQL | Aggregations, `CASE`, CTEs, `DENSE_RANK()`, and validation |
| Python | Data extraction and analytical workflow |
| Pandas | Data manipulation and aggregation |
| NumPy | Vectorized transformations and quality flags |
| Matplotlib | Distribution and quality diagnostic charts |
| Power BI | Interactive dashboard and reporting |
| DAX | KPI calculations and Year-to-Date analysis |
| GitHub | Version control and project documentation |

## Dataset Overview

The analyzed source contains **31,047 records and 21 columns**.

Important fields include:

- `order_id` — Order identifier
- `cust_id` — Customer identifier
- `gender` — Customer gender
- `age`, `age_group` — Customer age information
- `order_date`, `month` — Order date and month
- `status` — Order status
- `channel` — Sales channel
- `sku`, `category`, `size` — Product information
- `qty` — Quantity
- `amount` — Transaction amount
- `ship_city`, `ship_state` — Shipping location
- `ship_country`, `ship_postal_code` — Shipping details
- `b2b` — Business-to-business indicator

## Project Implementation

### 1. Excel — Initial Sales Dashboard

The Excel stage provides the initial business reporting baseline.

Analysis areas include:

- Overall sales performance
- Monthly revenue
- Gender-wise revenue contribution
- Sales channel performance
- Category and state-level sales analysis

The Excel dashboard is retained as the original reporting baseline for selected metric comparisons.

### 2. SQL — Business Analysis and Validation

The SQL script is organized into three main question groups.

**SQL-Q1: Dataset Structure and Baseline Validation**

- Inspect table structure using `DESCRIBE` and `SHOW CREATE TABLE`
- Calculate total records and revenue
- Compare source record count with unique order IDs
- Calculate unique customer count and total quantity
- Aggregate revenue by gender

**SQL-Q2: Multi-Flag Financial Reconciliation**

- Inspect available order statuses
- Classify records using `CASE`
- Report distinct orders, source records, and amount for each classification
- Check NULL and negative amounts by status
- Reconcile overall record count and revenue

Classification rules:

- `Valid Revenue`: Delivered records with positive amounts
- `Revenue Leak`: Delivered records with zero amounts
- `Reversal Check`: Cancelled, Refunded, or Returned records with positive amounts
- `Review`: Records not covered by the preceding rules

These are rule-based investigation labels. They do not independently prove an actual revenue leak, completed refund, or accounting loss. An order may also appear in more than one classification if its source records have different statuses.

**SQL-Q3: Channel and Category Revenue Ranking**

- Aggregate revenue by channel and category
- Apply `DENSE_RANK()` within each channel
- Return the highest-revenue category, including ties
- Calculate the top category's percentage contribution to channel revenue

This query returns the top-ranked category per channel; it is not a complete ranking of every category.

### 3. Python — Data Analysis and Quality Checks

The Jupyter notebook connects to MySQL and extracts the `vrinda_store_sales` table.

Implemented activities include:

- Dataset dimensions, column inspection, and data types
- Missing-value and full-row duplicate checks
- NumPy array creation and vectorized amount-band classification
- Revenue aggregation by gender and shipping state
- Standardization of state names using trimming and uppercase conversion
- Combining `NEW DELHI` with `DELHI` for consistent state-level reporting
- Quality flags based on non-positive quantities or negative amounts
- Matplotlib histograms for quantity and amount distributions
- A data-quality flag chart
- Reconciliation of selected metrics against the Excel baseline

The discounted amount and High/Medium/Low bands are practice transformations, not actual discount records or official business classifications.

### 4. Power BI — Interactive Dashboard

The Power BI report contains four pages.

**Page 1 — Main Dashboard**

KPI cards:

- Total Revenue
- Total Orders
- Total Customers
- Delivered Revenue
- Delivered Orders

Visuals:

- Total Revenue by Gender
- Total Revenue by Channel
- Total Revenue by Month

Slicers:

- Channel
- Gender
- Month

**Additional report pages**

- Total Revenue By Month
- Total Revenue By Channel
- Gender wise Revenue

**Data modeling and DAX**

- Date table with month, month number, year, and year-month fields
- Relationship between the sales table's order date and the date table
- Year-to-Date revenue measures
- Comparison of date-table and sales-table YTD results
- KPI and revenue validation under the all-data filter context

The report is designed to support interactive exploration of the main business metrics.

## Key Results

The following are the baseline values from the reviewed Excel/Python reconciliation and the Power BI report's all-data context.

| Metric | Result |
|---|---:|
| Total Records | 31,047 |
| Total Revenue | ₹21,176,377 |
| Unique Orders | 28,471 |
| Unique Customers | 28,437 |
| Delivered Revenue | ₹19,710,544 |
| Delivered Orders | 26,356 |
| Women's Revenue | ₹13,562,773 |
| Men's Revenue | ₹7,613,604 |
| Amazon Revenue | ₹7,519,933 |
| Set Category Revenue | ₹10,507,546 |
| Maharashtra Revenue | ₹2,990,221 |
| Delhi Revenue, after state standardization | ₹1,274,750 |

### Business Insights

- Women contributed approximately **64.05%** of total revenue.
- Men contributed approximately **35.95%** of total revenue.
- Amazon was the highest-revenue sales channel, contributing approximately **₹75.20 lakh**.
- The Set category generated approximately **₹1.05 crore**.
- March was the highest-revenue month, at approximately **₹19.28 lakh**.
- Delivered revenue was approximately **93.08%** of total revenue, using the report's implemented definitions.

These results describe the analyzed dataset; they do not establish the causes behind the observed patterns.

## Data Quality and Reconciliation

The Python notebook's implemented checks reported:

- 31,047 source records
- No missing values across the inspected columns
- Zero full-row duplicates
- Zero missing `qty` values
- Zero missing `amount` values
- Zero non-positive quantities under the implemented check
- Zero negative amounts under the implemented check
- All selected Excel-to-Python reconciliation metrics matched the defined baseline

The checks are limited to the fields, conditions, and baseline metrics implemented in the project. They do not guarantee the absence of every possible data-quality issue.

Repeated order IDs are not automatically duplicates: one order can be represented by multiple source records. Order counts and record counts must therefore be interpreted separately.

## Repository Structure

The following is the recommended structure for the repository. Update the filenames to match the files actually uploaded.

```text
Vrinda-Store-Sales-Dashboard/
│
├── README.md
├── Excel/
│   ├── Vrinda Store Data Analysis 2022.xlsx
│   └── Vrinda Dashboard in Excel.png
│
├── SQL/
│   └── vrinda_store_db.sql
│
├── Python/
│   └── Vrinda_Store_Project.ipynb
│
├── PowerBI/
│   └── Vrinda_store_analysis_2022.pbix
│
└── Screenshots/
    └── Vrinda_Store_PowerBI_Dashboard.png
```

## How to Run or Review the Project

1. Open the Excel workbook to review the initial dashboard.
2. Configure a local MySQL database named `vrinda_store_db` and ensure the `vrinda_store_sales` table exists.
3. Run the SQL script against the database containing that table.
4. Open the Python notebook in Jupyter or VS Code, install the required dependencies, and provide your own local MySQL credentials when prompted.
5. Open the `.pbix` file in Power BI Desktop to explore the dashboard and report pages.

**Security:** Database passwords and other credentials must not be committed to GitHub. Configure your own connection details locally.

## Skills Demonstrated

- SQL querying and business analysis
- Conditional logic, CTEs, and window functions
- Data extraction from MySQL
- Pandas and NumPy transformations
- Data-quality checks and exploratory analysis
- Matplotlib visualization
- Power BI dashboard design
- DAX and date-table analysis
- KPI validation and cross-tool reconciliation
- Business insight communication
- GitHub project documentation

## Conclusion

The Vrinda Store Analysis Report 2022 demonstrates an end-to-end retail analytics workflow across Excel, SQL, Python, and Power BI. It combines business-oriented SQL analysis, Python-based quality checks, metric reconciliation, and interactive business reporting in a single portfolio project.

**Project Domain:** Retail Sales Analytics and Business Intelligence

**Technology Stack:** Excel · MySQL · SQL · Python · Pandas · NumPy · Matplotlib · Power BI · DAX
