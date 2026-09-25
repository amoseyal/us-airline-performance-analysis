# U.S. Airline Performance Analysis
# Data Import and Cleaning


# Load packages

library(tidyverse)
library(lubridate)
library(janitor)
library(here)
library(DBI)
library(duckdb)


# Locate data files

data_files <- list.files(
  here("data", "raw"),
  pattern = "^bts_ontime_2025_[0-9]{2}\\.csv$",
  full.names = TRUE
)

if (length(data_files) != 12) {
  stop(
    "Expected 12 monthly BTS files, but found ",
    length(data_files),
    "."
  )
}


# Connect to DuckDB

con <- dbConnect(duckdb())

temp_dir <- here("data", "temp")

dir.create(
  temp_dir,
  showWarnings = FALSE,
  recursive = TRUE
)

invisible(
  dbExecute(
    con,
    paste0(
      "SET temp_directory = '",
      temp_dir,
      "'"
    )
  )
)

csv_pattern <- here(
  "data",
  "raw",
  "bts_ontime_2025_*.csv"
)


# Import data

invisible(
  dbExecute(
    con,
    paste0(
      "CREATE OR REPLACE TABLE flights_raw AS ",
      "SELECT * FROM read_csv_auto('",
      csv_pattern,
      "', union_by_name = true)"
    )
  )
)


# Standardize column names

original_names <- dbListFields(con, "flights_raw")
clean_names <- make_clean_names(original_names)

rename_sql <- paste(
  sprintf(
    '"%s" AS "%s"',
    original_names,
    clean_names
  ),
  collapse = ", "
)

invisible(
  dbExecute(
    con,
    paste0(
      "CREATE OR REPLACE TABLE flights_named AS ",
      "SELECT ",
      rename_sql,
      " FROM flights_raw"
    )
  )
)


# Clean data

invisible(
  dbExecute(
    con,
    "
    CREATE OR REPLACE TABLE flights_clean AS
    SELECT
      * EXCLUDE (
        fl_date,
        dep_del15,
        arr_del15,
        cancelled,
        diverted
      ),
      CAST(fl_date AS DATE) AS fl_date,
      CASE
        WHEN dep_del15 IS NULL THEN NULL
        ELSE dep_del15 = 1
      END AS dep_del15,
      CASE
        WHEN arr_del15 IS NULL THEN NULL
        ELSE arr_del15 = 1
      END AS arr_del15,
      CASE
        WHEN cancelled IS NULL THEN NULL
        ELSE cancelled = 1
      END AS cancelled,
      CASE
        WHEN diverted IS NULL THEN NULL
        ELSE diverted = 1
      END AS diverted
    FROM flights_named
    "
  )
)


# Validate cleaned data

duplicate_check <- dbGetQuery(
  con,
  "
  SELECT
    COUNT(*) - COUNT(*) OVER () AS placeholder
  FROM flights_clean
  LIMIT 0
  "
)

total_rows <- dbGetQuery(
  con,
  "
  SELECT COUNT(*) AS total_rows
  FROM flights_clean
  "
)$total_rows

unique_rows <- dbGetQuery(
  con,
  "
  SELECT COUNT(*) AS unique_rows
  FROM (
    SELECT DISTINCT *
    FROM flights_clean
  )
  "
)$unique_rows

exact_duplicates <- total_rows - unique_rows

cat(
  "\nExact duplicate rows:",
  exact_duplicates,
  "\n\n"
)

missing_values <- dbGetQuery(
  con,
  "
  SELECT
    SUM(CASE WHEN fl_date IS NULL THEN 1 ELSE 0 END)
      AS missing_date,
    SUM(CASE WHEN op_unique_carrier IS NULL THEN 1 ELSE 0 END)
      AS missing_carrier,
    SUM(CASE WHEN origin IS NULL THEN 1 ELSE 0 END)
      AS missing_origin,
    SUM(CASE WHEN dest IS NULL THEN 1 ELSE 0 END)
      AS missing_destination,
    SUM(CASE WHEN distance IS NULL THEN 1 ELSE 0 END)
      AS missing_distance
  FROM flights_clean
  "
)

print(missing_values)

flight_summary <- dbGetQuery(
  con,
  "
  SELECT
    COUNT(*) AS total_flights,
    SUM(CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END)
      AS cancelled_flights,
    SUM(CASE WHEN diverted = TRUE THEN 1 ELSE 0 END)
      AS diverted_flights,
    SUM(CASE WHEN arr_del15 = TRUE THEN 1 ELSE 0 END)
      AS delayed_arrivals
  FROM flights_clean
  "
)

print(flight_summary)

coverage_check <- dbGetQuery(
  con,
  "
  SELECT
    COUNT(DISTINCT month) AS months,
    MIN(month) AS first_month,
    MAX(month) AS last_month
  FROM flights_clean
  "
)

print(coverage_check)


# Save processed data

dir.create(
  here("data", "processed"),
  showWarnings = FALSE,
  recursive = TRUE
)

processed_file <- here(
  "data",
  "processed",
  "flights_2025.parquet"
)

invisible(
  dbExecute(
    con,
    paste0(
      "COPY flights_clean TO '",
      processed_file,
      "' (FORMAT PARQUET, COMPRESSION ZSTD)"
    )
  )
)


# Report output

column_count <- dbGetQuery(
  con,
  "
  SELECT COUNT(*) AS column_count
  FROM information_schema.columns
  WHERE table_name = 'flights_clean'
  "
)$column_count

cat(
  "\nNumber of rows:",
  total_rows,
  "\n"
)

cat(
  "Number of columns:",
  column_count,
  "\n"
)

cat(
  "Processed data saved to:",
  processed_file,
  "\n"
)


# Disconnect from DuckDB

dbDisconnect(con, shutdown = TRUE)