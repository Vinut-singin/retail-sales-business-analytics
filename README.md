# Retail Sales & Business Performance Analytics

## Project Overview
This project analyzes retail sales data using **MySQL and Power BI** to evaluate sales performance, profitability, product trends, customer segments, and regional performance. It demonstrates how SQL can transform raw transactional data into actionable business insights and how Power BI can present key metrics through an interactive dashboard.

## Business Objectives
- Evaluate overall sales, profit, order volume, and profit margin.
- Analyze monthly sales and profit trends to understand business performance over time.
- Identify high-performing and underperforming product categories and sub-categories.
- Compare regional and customer-segment performance.
- Examine the relationship between discounts and profitability.
- Develop an interactive dashboard to support data-driven decision-making.

## Tools & Technologies
- **SQL:** MySQL 8+
- **Data Visualization:** Microsoft Power BI
- **Data Transformation:** SQL queries and Power Query
- **Analytical Techniques:** Aggregations, joins, Common Table Expressions (CTEs), window functions, date-based analysis, and KPI calculations.

## Dataset
**Sample Superstore Dataset**

Source: [Kaggle – Sample Superstore Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

The dataset contains sample retail transaction information, including order dates, sales, profit, discounts, product categories, customer segments, and geographical details.

*Note: The dataset represents sample business data and does not reflect the internal performance of a real company.*

## Project Workflow

### 1. Data Preparation
- Imported the dataset into MySQL.
- Standardized column names and verified data types.
- Checked for missing values, duplicate records, and potential data-quality issues.
- Prepared the dataset for consistent analysis.

### 2. SQL-Based Business Analysis
Used MySQL queries to analyze business performance across multiple dimensions:

- **KPI Analysis:** Total sales, total profit, order count, average order value, and profit margin.
- **Time-Series Analysis:** Monthly sales and profit trends, month-over-month changes, and year-over-year comparisons where the data supports them.
- **Product Analysis:** Category and sub-category performance, including sales and profitability.
- **Regional Analysis:** Comparison of sales and profit across geographical regions.
- **Customer Analysis:** Performance across customer segments and contribution to overall sales.
- **Discount Analysis:** Evaluation of discount levels and their relationship with profitability.
- **Shipping Analysis:** Examination of shipping modes and associated sales performance.

### 3. Power BI Dashboard
Designed a one-page dashboard concept to present key business metrics and trends in an accessible format.

Planned dashboard components include:
- KPI cards for sales, profit, orders, and profit margin.
- Monthly sales and profit trend charts.
- Category and sub-category performance visuals.
- Regional and customer-segment comparisons.
- Interactive slicers for filtering the analysis.

The dashboard should be validated in Power BI before being presented as a completed deliverable.

## Repository Structure

```text
retail-sales-business-analytics/
├── retail_sales_analysis.sql
├── power_bi_measures_and_dashboard_guide.txt
├── dashboard_layout.png
└── README.md
```

## How to Run the Project

### Step 1: Download the Dataset
Download the Sample Superstore CSV from the Kaggle link provided above.

### Step 2: Import the Data into MySQL
Import the CSV into MySQL and create a table named `superstore`. Ensure the column names and data types match those expected by the SQL script.

### Step 3: Run the SQL Queries
Open `retail_sales_analysis.sql` in your MySQL environment and execute the sections in order. Review the outputs and validate the results.

### Step 4: Build the Power BI Dashboard
Import the dataset into Power BI, confirm column data types, and create the DAX measures listed in `power_bi_measures_and_dashboard_guide.txt`.

### Step 5: Validate the Results
Check KPI calculations, date sorting, filter interactions, and consistency between SQL outputs and Power BI visuals.

## Key Deliverables
- SQL queries for retail sales and profitability analysis.
- Business KPI calculations and trend analysis.
- Product, regional, customer, discount, and shipping analysis.
- Power BI dashboard design and measure documentation.
- A reproducible workflow for retail business performance analysis.

## Business Value
This project demonstrates the use of SQL and business intelligence techniques to organize transactional data, monitor performance metrics, investigate profitability patterns, and communicate findings that can support business decisions.

## Future Improvements
- Add verified business findings and recommendations based on query results.
- Publish the completed Power BI dashboard with screenshots.
- Automate data refresh and reporting.
- Extend the analysis with sales forecasting and advanced time-series methods.

---

**Project Status:** Update this section to reflect the actual implementation status before publishing. Mark the project as completed only after executing and validating the SQL analysis and building and testing the Power BI dashboard.
