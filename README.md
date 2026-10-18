# Retail Sales & Business Performance Analytics

## Contents
- `retail_sales_analysis.sql`: MySQL 8+ schema and analysis queries.
- `power_bi_measures_and_dashboard_guide.txt`: DAX measures and dashboard construction guide.
- `dashboard_layout.png`: visual layout reference for a one-page Power BI report.

## Dataset
Use the public Sample Superstore dataset:
https://www.kaggle.com/datasets/vivek468/superstore-dataset-final

This project is designed for practice and placement preparation. The dataset is sample data and does not represent a real company's internal performance.

## How to use the SQL script
1. Download the CSV.
2. Import it into MySQL as a table named `superstore`.
3. Normalize column names to the snake_case names in the SQL script, or adjust the script to match your import.
4. Run sections in order.
5. Record the actual results; do not invent findings.

## How to build the Power BI report
1. Import the CSV into Power BI Desktop (Windows) or use an available supported Power BI environment.
2. Rename the table to `Superstore`.
3. Confirm date and numeric data types.
4. Create the measures in `power_bi_measures_and_dashboard_guide.txt`.
5. Build the visuals in the guide, using `dashboard_layout.png` as a reference.
6. Validate that slicers work and that monthly dates sort chronologically.

## Honest resume wording
Only list this as a completed project after running the SQL and building/testing the dashboard. If you have only prepared the materials, label it `Retail Sales Analytics (In Progress)` and describe only the parts you actually completed.
