# U.S. Airline Performance Analysis

An end-to-end analysis of more than **7 million U.S. scheduled passenger flights in 2025**, examining delays, cancellations, airline and airport performance, delay attribution, and frequently operated routes.

Built with **R, DuckDB, SQL, Parquet, ggplot2, and Quarto** using data from the U.S. Bureau of Transportation Statistics.

## Project Overview

This project analyzes U.S. airline operational performance during 2025 to identify when disruptions occurred, where they were concentrated, and how performance varied across the national air transportation network.

The analysis addresses five primary questions:

- How did flight delays and cancellations change throughout the year?
- How did arrival-delay performance vary across operating carriers?
- How did departure-delay rates vary among higher-volume U.S. airports?
- Which reported causes accounted for the greatest number of delay minutes?
- Which frequently operated routes experienced the highest arrival-delay rates?

The complete dataset contains **7,001,619 flight records across 45 variables and all 12 months of 2025**.

## Key Findings

- **22.31%** of eligible completed flights arrived at least 15 minutes late, while **1.47%** of scheduled flights were cancelled.
- Arrival delays showed strong seasonality, peaking at **28.89% in July** and reaching a low of **16.63% in September**.
- Cancellation patterns differed from arrival delays, with the highest cancellation rate occurring in **January at 3.02%**.
- Arrival-delay rates varied from **17.28% to 27.91%** across the 14 operating carriers represented in the dataset.
- **Late-aircraft and carrier delays accounted for approximately 72%** of the 111.9 million minutes attributed across the five BTS delay categories.
- Among 2,342 directional routes with at least 1,000 annual flights, several recorded arrival-delay rates above **35%**.

## Visualizations

### Monthly Arrival Delay Rate

  <img src="figures/monthly_arrival_delay_rate.png"
       alt="Monthly U.S. arrival delay rate"
       width="700">


### Airline Arrival Delay Rate

  <img src="figures/airline_arrival_delay_rate.png"
       alt="Arrival delay rates by airline"
       width="700">


### Airport Delay Rate vs. Traffic Volume

  <img src="figures/airport_delay_rate_vs_departures.png"
       alt="Airport delay rate versus departures"
       width="700">


### Reported Sources of Delay

  <img src="figures/delay_causes.png"
       alt="Attributed delay minutes by cause"
       width="700">


### High-Delay Routes

  <img src="figures/high_delay_routes.png"
       alt="Highest-delay frequently operated routes"
       width="700">


## Data and Methodology

The project uses 2025 **On-Time Performance** data published by the U.S. Bureau of Transportation Statistics.

The analytical workflow is separated into four stages:

1. **Data preparation** - twelve monthly source files are validated, standardized, and combined.
2. **Analysis** - the cleaned 7-million-row dataset is stored in Parquet format and queried with DuckDB.
3. **Visualization** - summarized analytical outputs are transformed into report-ready figures with ggplot2.
4. **Reporting** - Quarto integrates the methodology, findings, visualizations, and limitations into a reproducible analytical report.

Airport comparisons are limited to airports with at least **10,000 annual scheduled departures**, while route comparisons require at least **1,000 scheduled flights**.

## Technical Stack

| Tool | Purpose |
|---|---|
| R | Data preparation and analysis |
| DuckDB / SQL | Analytical querying |
| Parquet | Efficient columnar data storage |
| tidyverse | Data transformation |
| ggplot2 | Data visualization |
| viridis | Visualization color scales |
| Quarto | Analytical reporting |
| Git / GitHub | Version control and project documentation |

## Repository Structure

```text
us-airline-performance-analysis/
├── R/
│   ├── 01_import_clean.R
│   ├── 02_analysis.R
│   └── 03_visualizations.R
├── data/
│   ├── raw/
│   └── processed/
│       └── analysis/
├── figures/
├── README.md
├── report.qmd
└── report.html
```

## Reproducing the Analysis

With the required BTS source data available, run the pipeline from the project root:

```bash
Rscript R/01_import_clean.R
Rscript R/02_analysis.R
Rscript R/03_visualizations.R
quarto render report.qmd
```

## Full Report

For the complete methodology, analysis, visualizations, interpretation, and limitations:

**[View the full analytical report](report.html)**

The underlying Quarto source is available in [`report.qmd`](report.qmd).

## Data Source

U.S. Bureau of Transportation Statistics - On-Time Performance data.