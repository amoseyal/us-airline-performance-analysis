# U.S. Airline Performance Analysis
# Exploratory Data Analysis


# Load packages

library(tidyverse)
library(here)
library(DBI)
library(duckdb)


# Connect to DuckDB

con <- dbConnect(duckdb())

data_file <- here(
  "data",
  "processed",
  "flights_2025.parquet"
)


# Overall performance

overall_performance <- dbGetQuery(
  con,
  paste0(
    "
    SELECT
      COUNT(*) AS total_flights,

      SUM(
        CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END
      ) AS cancelled_flights,

      SUM(
        CASE WHEN diverted = TRUE THEN 1 ELSE 0 END
      ) AS diverted_flights,

      SUM(
        CASE WHEN arr_del15 = TRUE THEN 1 ELSE 0 END
      ) AS delayed_arrivals,

      ROUND(
        100.0 * SUM(
          CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
      ) AS cancellation_rate,

      ROUND(
        100.0 * SUM(
          CASE WHEN arr_del15 = TRUE THEN 1 ELSE 0 END
        )
        / SUM(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
              AND arr_del15 IS NOT NULL
            THEN 1
            ELSE 0
          END
        ),
        2
      ) AS arrival_delay_rate,

      ROUND(
        AVG(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS avg_arrival_delay,

      ROUND(
        MEDIAN(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS median_arrival_delay

    FROM read_parquet('",
    data_file,
    "')
    "
  )
)

print(overall_performance)


# Monthly performance

monthly_performance <- dbGetQuery(
  con,
  paste0(
    "
    SELECT
      month,
      COUNT(*) AS total_flights,

      ROUND(
        100.0 * SUM(
          CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
      ) AS cancellation_rate,

      ROUND(
        100.0 * SUM(
          CASE WHEN arr_del15 = TRUE THEN 1 ELSE 0 END
        )
        / SUM(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
              AND arr_del15 IS NOT NULL
            THEN 1
            ELSE 0
          END
        ),
        2
      ) AS arrival_delay_rate,

      ROUND(
        AVG(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS avg_arrival_delay,

      ROUND(
        MEDIAN(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS median_arrival_delay

    FROM read_parquet('",
    data_file,
    "')
    GROUP BY month
    ORDER BY month
    "
  )
)

print(monthly_performance)


# Airline performance

airline_performance <- dbGetQuery(
  con,
  paste0(
    "
    SELECT
      op_unique_carrier AS carrier,
      COUNT(*) AS total_flights,

      ROUND(
        100.0 * SUM(
          CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
      ) AS cancellation_rate,

      ROUND(
        100.0 * SUM(
          CASE WHEN arr_del15 = TRUE THEN 1 ELSE 0 END
        )
        / SUM(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
              AND arr_del15 IS NOT NULL
            THEN 1
            ELSE 0
          END
        ),
        2
      ) AS arrival_delay_rate,

      ROUND(
        AVG(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS avg_arrival_delay,

      ROUND(
        MEDIAN(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS median_arrival_delay

    FROM read_parquet('",
    data_file,
    "')
    GROUP BY op_unique_carrier
    ORDER BY arrival_delay_rate DESC
    "
  )
)

print(airline_performance)


# Airport performance

airport_performance <- dbGetQuery(
  con,
  paste0(
    "
    SELECT
      origin AS airport,
      origin_city_name AS city,
      COUNT(*) AS departures,

      ROUND(
        100.0 * SUM(
          CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
      ) AS cancellation_rate,

      ROUND(
        100.0 * SUM(
          CASE WHEN dep_del15 = TRUE THEN 1 ELSE 0 END
        )
        / SUM(
          CASE
            WHEN cancelled = FALSE
              AND dep_del15 IS NOT NULL
            THEN 1
            ELSE 0
          END
        ),
        2
      ) AS departure_delay_rate,

      ROUND(
        AVG(
          CASE
            WHEN cancelled = FALSE
            THEN dep_delay
          END
        ),
        2
      ) AS avg_departure_delay

    FROM read_parquet('",
    data_file,
    "')

    GROUP BY
      origin,
      origin_city_name

    HAVING COUNT(*) >= 10000

    ORDER BY departure_delay_rate DESC
    "
  )
)

print(airport_performance)


# Delay causes

delay_causes <- dbGetQuery(
  con,
  paste0(
    "
    SELECT
      ROUND(SUM(carrier_delay), 0) AS carrier_delay_minutes,
      ROUND(SUM(weather_delay), 0) AS weather_delay_minutes,
      ROUND(SUM(nas_delay), 0) AS nas_delay_minutes,
      ROUND(SUM(security_delay), 0) AS security_delay_minutes,
      ROUND(SUM(late_aircraft_delay), 0) AS late_aircraft_delay_minutes
    FROM read_parquet('",
    data_file,
    "')
    "
  )
)

print(delay_causes)


# Route performance

route_performance <- dbGetQuery(
  con,
  paste0(
    "
    SELECT
      origin,
      dest,
      COUNT(*) AS total_flights,

      ROUND(
        100.0 * SUM(
          CASE WHEN arr_del15 = TRUE THEN 1 ELSE 0 END
        )
        / SUM(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
              AND arr_del15 IS NOT NULL
            THEN 1
            ELSE 0
          END
        ),
        2
      ) AS arrival_delay_rate,

      ROUND(
        AVG(
          CASE
            WHEN cancelled = FALSE
              AND diverted = FALSE
            THEN arr_delay
          END
        ),
        2
      ) AS avg_arrival_delay,

      ROUND(
        100.0 * SUM(
          CASE WHEN cancelled = TRUE THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
      ) AS cancellation_rate

    FROM read_parquet('",
    data_file,
    "')

    GROUP BY
      origin,
      dest

    HAVING COUNT(*) >= 1000

    ORDER BY arrival_delay_rate DESC
    "
  )
)

print(head(route_performance, 15))

cat(
  "\nNumber of qualifying routes:",
  nrow(route_performance),
  "\n"
)


# Disconnect from DuckDB

dbDisconnect(con, shutdown = TRUE)