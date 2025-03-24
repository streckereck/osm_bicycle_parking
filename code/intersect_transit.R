library(mapview)
library(sf)
library(tidyverse)

# buffer on transit stations to identify bicycle parking near transit

study_cities_bike_parking <- st_read("data/bicycle_parking_study_cities.gpkg")
study_cities_transit <- st_read("data/study_cities_transit.gpkg")

# create buffers
buffer_meters <- 125
study_cities_transit_buffers <- study_cities_transit %>%
  st_buffer(125)

# intersect parking
study_cities_bike_parking_buffers <- study_cities_bike_parking %>%
  st_intersection(study_cities_transit_buffers[,"name"])

ids_in_buffers <- unique(study_cities_bike_parking_buffers$osm_id)

study_cities_bike_parking <- study_cities_bike_parking %>%
  mutate(
    near_transit_hub = osm_id %in% study_cities_bike_parking_buffers$osm_id
  )

# visual check
mapview(study_cities_transit_buffers, col.regions = "grey") +
  mapview(study_cities_bike_parking) + 
  mapview(study_cities_bike_parking %>% filter(near_transit_hub), col.regions = "red")

st_write(study_cities_bike_parking, 
         "data/bicycle_parking_study_cities.gpkg",
         delete_dsn = T)

st_write(study_cities_transit_buffers, 
         "data/study_cities_transit_buffers.gpkg",
         delete_dsn = T)
