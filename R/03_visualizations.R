# U.S. Airline Performance Analysis
# Data Visualizations


# Load packages

library(tidyverse)
library(here)
library(viridis)
library(ggrepel)


# Load analysis results

analysis_dir <- here(
  "data",
  "processed",
  "analysis"
)

overall_performance <- read_csv(
  file.path(analysis_dir, "overall_performance.csv"),
  show_col_types = FALSE
)

monthly_performance <- read_csv(
  file.path(analysis_dir, "monthly_performance.csv"),
  show_col_types = FALSE
)

airline_performance <- read_csv(
  file.path(analysis_dir, "airline_performance.csv"),
  show_col_types = FALSE
)

airport_performance <- read_csv(
  file.path(analysis_dir, "airport_performance.csv"),
  show_col_types = FALSE
)

delay_causes <- read_csv(
  file.path(analysis_dir, "delay_causes.csv"),
  show_col_types = FALSE
)

route_performance <- read_csv(
  file.path(analysis_dir, "route_performance.csv"),
  show_col_types = FALSE
)


# Create output directory

figures_dir <- here("figures")

dir.create(
  figures_dir,
  showWarnings = FALSE,
  recursive = TRUE
)


# Monthly arrival delay rate

monthly_delay_plot <- monthly_performance %>%
  mutate(
    month = factor(
      month,
      levels = 1:12,
      labels = month.abb
    )
  ) %>%
  ggplot(
    aes(
      x = month,
      y = arrival_delay_rate,
      group = 1
    )
  ) +
  geom_line(
    linewidth = 1.1,
    color = viridis(5)[3]
  ) +
  geom_point(
    size = 3,
    color = viridis(5)[3]
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1),
    limits = c(0, 35)
  ) +
  labs(
    title = "Arrival Delays Peaked During the Summer",
    subtitle = "Share of eligible U.S. flights arriving at least 15 minutes late, 2025",
    x = NULL,
    y = "Arrival Delay Rate",
    caption = "Source: U.S. Bureau of Transportation Statistics"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title.y = element_text(
        margin = margin(r = 12)
    ),
    plot.caption = element_text(
        size = 8,
        hjust = 1,
        margin = margin(t = 12)
    )
  )

monthly_delay_plot

# Save visualization

ggsave(
  file.path(
    figures_dir,
    "monthly_arrival_delay_rate.png"
  ),
  plot = monthly_delay_plot,
  width = 10,
  height = 6,
  dpi = 300
)


# Monthly cancellation rate

monthly_cancellation_plot <- monthly_performance %>%
  mutate(
    month = factor(
      month,
      levels = 1:12,
      labels = month.abb
    )
  ) %>%
  ggplot(
    aes(
      x = month,
      y = cancellation_rate,
      fill = cancellation_rate
    )
  ) +
  geom_col(
    width = 0.7
  ) +
  scale_fill_viridis_c(
    option = "cividis",
    direction = -1,
    guide = "none"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1),
    limits = c(0, 3.5),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "Flight Cancellations Varied Sharply by Month",
    subtitle = "Share of scheduled U.S. flights cancelled, 2025",
    x = NULL,
    y = "Cancellation Rate",
    caption = "Source: U.S. Bureau of Transportation Statistics"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title.y = element_text(
      margin = margin(r = 12)
    ),
    plot.caption = element_text(
      size = 8,
      hjust = 1,
      margin = margin(t = 12)
    )
  )

monthly_cancellation_plot

# Save visualization

ggsave(
  file.path(
    figures_dir,
    "monthly_cancellation_rate.png"
  ),
  plot = monthly_cancellation_plot,
  width = 10,
  height = 6,
  dpi = 300
)


# Airline arrival delay rate

airline_plot_data <- airline_performance %>%
  mutate(
    airline = case_when(
      carrier == "F9" ~ "Frontier (F9)",
      carrier == "OH" ~ "PSA (OH)",
      carrier == "B6" ~ "JetBlue (B6)",
      carrier == "AA" ~ "American (AA)",
      carrier == "G4" ~ "Allegiant (G4)",
      carrier == "AS" ~ "Alaska (AS)",
      carrier == "YX" ~ "Republic (YX)",
      carrier == "UA" ~ "United (UA)",
      carrier == "NK" ~ "Spirit (NK)",
      carrier == "WN" ~ "Southwest (WN)",
      carrier == "MQ" ~ "Envoy (MQ)",
      carrier == "OO" ~ "SkyWest (OO)",
      carrier == "DL" ~ "Delta (DL)",
      carrier == "HA" ~ "Hawaiian (HA)",
      TRUE ~ carrier
    ),
    airline = reorder(
      airline,
      arrival_delay_rate
    )
  )

  airline_delay_plot <- airline_plot_data %>%
  ggplot(
    aes(
      x = arrival_delay_rate,
      y = airline,
      fill = arrival_delay_rate
    )
  ) +
  geom_col(
    width = 0.7
  ) +
  scale_fill_viridis_c(
    option = "mako",
    direction = -1,
    guide = "none"
  ) +
  scale_x_continuous(
    labels = scales::label_percent(scale = 1),
    limits = c(0, 32),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Arrival Delay Rates Varied Across U.S. Airlines",
    subtitle = "Share of eligible flights arriving at least 15 minutes late, 2025",
    x = "Arrival Delay Rate",
    y = NULL,
    caption = "Source: U.S. Bureau of Transportation Statistics"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title.x = element_text(
      margin = margin(t = 12)
    ),
    plot.caption = element_text(
      size = 8,
      hjust = 1,
      margin = margin(t = 12)
    )
  )

# Save visualization

ggsave(
  file.path(
    figures_dir,
    "airline_arrival_delay_rate.png"
  ),
  plot = airline_delay_plot,
  width = 10,
  height = 7,
  dpi = 300
)


# Airport departure delay rate and flight volume

airport_labels <- airport_performance %>%
  filter(
    airport %in% c(
      "SFB",
      "DFW",
      "DEN",
      "ORD",
      "ATL"
    )
  )

airport_performance_plot <- airport_performance %>%
  ggplot(
    aes(
      x = departures,
      y = departure_delay_rate,
      color = departure_delay_rate
    )
  ) +
  geom_point(
    size = 3,
    alpha = 0.8
  ) +
  geom_text_repel(
  data = airport_labels,
  aes(label = airport),
  size = 3.5,
  fontface = "bold",
  box.padding = 0.5,
  point.padding = 0.4,
  min.segment.length = 0,
  show.legend = FALSE
  ) +
  scale_color_viridis_c(
    option = "viridis",
    direction = -1,
    guide = "none"
  ) +
  scale_x_continuous(
    labels = scales::label_number(
      scale = 0.001,
      suffix = "K"
    ),
    expand = expansion(mult = c(0.02, 0.05))
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1),
    limits = c(10, 32)
  ) +
  labs(
    title = "Airport Delay Rates Varied Across Traffic Volumes",
    subtitle = "U.S. airports with at least 10,000 scheduled departures, 2025",
    x = "Annual Departures",
    y = "Departure Delay Rate",
    caption = "Source: U.S. Bureau of Transportation Statistics"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title.x = element_text(
      margin = margin(t = 12)
    ),
    axis.title.y = element_text(
      margin = margin(r = 12)
    ),
    plot.caption = element_text(
      size = 8,
      hjust = 1,
      margin = margin(t = 12)
    )
  )

airport_performance_plot

# Save visualization

ggsave(
  file.path(
    figures_dir,
    "airport_delay_rate_vs_departures.png"
  ),
  plot = airport_performance_plot,
  width = 10,
  height = 6,
  dpi = 300
)


# Delay causes

delay_causes_plot_data <- delay_causes %>%
  pivot_longer(
    cols = everything(),
    names_to = "cause",
    values_to = "delay_minutes"
  ) %>%
  mutate(
    cause = recode(
      cause,
      carrier_delay_minutes = "Carrier",
      weather_delay_minutes = "Weather",
      nas_delay_minutes = "National Aviation System",
      security_delay_minutes = "Security",
      late_aircraft_delay_minutes = "Late Aircraft"
    ),
    cause = reorder(
      cause,
      delay_minutes
    ),
    delay_minutes_millions = delay_minutes / 1000000
  )

  delay_causes_plot <- delay_causes_plot_data %>%
  ggplot(
    aes(
      x = delay_minutes_millions,
      y = cause
    )
  ) +
  geom_col(
    width = 0.7,
    fill = viridis(5)[2]
  ) +
  scale_x_continuous(
    labels = scales::label_number(
      accuracy = 1,
      suffix = "M"
    ),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "Late Aircraft Generated the Most Attributed Delay Minutes",
    subtitle = "Total delay minutes by BTS-reported cause, U.S. flights, 2025",
    x = "Delay Minutes",
    y = NULL,
    caption = "Source: U.S. Bureau of Transportation Statistics"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title.x = element_text(
      margin = margin(t = 12)
    ),
    plot.caption = element_text(
      size = 8,
      hjust = 1,
      margin = margin(t = 12)
    )
  )

delay_causes_plot

# Save visualization

ggsave(
  file.path(
    figures_dir,
    "delay_causes.png"
  ),
  plot = delay_causes_plot,
  width = 10,
  height = 6,
  dpi = 300
)


# High-delay routes

route_plot_data <- route_performance %>%
  slice_max(
    order_by = arrival_delay_rate,
    n = 15,
    with_ties = FALSE
  ) %>%
  mutate(
    route = paste(
      origin,
      "\u2192",
      dest
    ),
    route = reorder(
      route,
      arrival_delay_rate
    )
  )

  route_delay_plot <- route_plot_data %>%
  ggplot(
    aes(
      x = arrival_delay_rate,
      y = route,
    )
  ) +
  geom_col(
    width = 0.7,
    fill = viridis(5)[1]
  ) +
  scale_x_continuous(
    labels = scales::label_percent(scale = 1),
    limits = c(0, 45),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Highest-Delay Routes Among Frequently Operated Routes",
    subtitle = "Routes with at least 1,000 scheduled flights, ranked by arrival delay rate, 2025",
    x = "Arrival Delay Rate",
    y = NULL,
    caption = "Source: U.S. Bureau of Transportation Statistics"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title.x = element_text(
      margin = margin(t = 12)
    ),
    plot.caption = element_text(
      size = 8,
      hjust = 1,
      margin = margin(t = 12)
    )
  )

route_delay_plot

# Save visualization

ggsave(
  file.path(
    figures_dir,
    "high_delay_routes.png"
  ),
  plot = route_delay_plot,
  width = 10,
  height = 7,
  dpi = 300
)