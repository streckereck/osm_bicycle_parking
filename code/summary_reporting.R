library(sf)
library(tidyverse)

study_cities_bike_parking <- st_read("data/bicycle_parking_study_cities.gpkg")

# create table 
# all study cities and by study city;
# city-wide and near-transit

overall_summary <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  mutate(name.1 = "All study cities") %>%
  group_by(name.1, can_park_class) %>%
  summarise(count = n()) %>%
  mutate(
    location = "City-wide",
    percent = count / sum(count))

overall_summary_transit <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  filter(near_transit_hub) %>%
  mutate(name.1 = "All study cities") %>%
  group_by(name.1, can_park_class) %>%
  summarise(count = n()) %>%
  mutate(
    location = "Near transit",
    percent = count / sum(count))

overall_summary <- overall_summary %>%
  rbind(overall_summary_transit)

# create table by city
overall_summary_city <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  group_by(name.1, can_park_class) %>%
  summarise(count = n()) %>%
  mutate(
    location = "City-wide",
    percent = count / sum(count))

overall_summary_transit_city <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  filter(near_transit_hub) %>%
  group_by(name.1, can_park_class) %>%
  summarise(count = n()) %>%
  mutate(
    location = "Near transit",
    percent = count / sum(count))

overall_summary_city <- overall_summary_city %>%
  rbind(overall_summary_transit_city)

overall_summary <- rbind(overall_summary,
                         overall_summary_city) %>%
  rename(place = name.1) %>%
  mutate(
    count = replace_na(count, 0),
    percent = replace_na(percent, 0)
  ) %>%
  select(
    place, location, can_park_class, count, percent
  )

write_csv(overall_summary, "data/overall_summary.csv")