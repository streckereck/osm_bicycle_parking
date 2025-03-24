library(sf)
library(tidyverse)

# export a clean version for sharing
bike_parking <- st_read("data/bicycle_parking_study_cities.gpkg")
transit_station_buffers <- st_read("data/study_cities_transit_buffers.gpkg")

bike_parking %>%
  select(osm_id,
         name,
         description,
         can_park_class,
         place = name.1) %>%
  st_write("data/bike_parking_24March2025.gpkg")

bike_parking %>%
  rename(place = name.1) %>%
  st_write("data/bike_parking_full_24March2025.gpkg")

transit_station_buffers %>%
  rename(place = name.1) %>%
  st_write("data/transit_station_buffers_24March2025.gpkg")
