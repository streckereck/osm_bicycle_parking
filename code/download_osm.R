library(mapview)
library(osmdata)
library(sf)
library(tidyverse)

# set the study area boundaries, download bike parking, download transit 
# stations, buffer, and intersect

target.projection <- 3348 # stats can albers

study_cities <- c(
  "Metro Vancouver, British Columbia",
  "Toronto, Ontario",
  "Montreal, Quebec",
  "Capital Regional District",
  "Kingston, Ontario",
  "Guelph, Ontario",
  "Calgary, Alberta",
  "Saskatchewan", # get all of sask and clip to study area in Saskatoon
  "Halifax, Nova Scotia")

# get polygons for clip
boundaries <- st_read("data/boundaries.gpkg")

# functions to manage different geometric representations of features (points/
# polygons) by taking the centroids of polygons and combining

# function to remove any nodes that fall on polygon boundaries (on OSM, these 
# are usually nodes that are part of the polygon)

removePointsOnLines <- function(points, polygons){
  # check both are in target projection
  points <- points %>%
    st_transform(target.projection)
  
  polygons <- polygons %>% 
    st_transform(target.projection)
  
  polygons.lines <- polygons %>%
    st_cast("MULTILINESTRING")
  
  points.overlapping <- points %>%
    st_intersection(st_buffer(polygons.lines,1))
  
  points <- points[-which(points$osm_id %in%
                            points.overlapping$osm_id), ]
  
  return(points)
}

# combine polgon and point features using the cetriods of polygons
combine_points_polys <- function(dataset){
  dataset_points <- dataset$osm_points %>% st_transform(target.projection)
  dataset_polygons <- dataset$osm_polygons %>% st_transform(target.projection)
  
  dataset_polygons_centroids <- st_centroid(dataset_polygons)
  dataset_points <- removePointsOnLines(dataset_points, dataset_polygons)
  
  dataset_points_all <- bind_rows(
    dataset_points,
    dataset_polygons_centroids
  )
  
  # mapview(dataset_points_all) + 
  #   mapview(dataset_polygons, col.regions = "red")
  
  return(dataset_points_all)
}

################################################################################
# Bike parking
################################################################################

get_bike_parking <- function(name_of_place){
  parking = NULL
  
  for(i in 1:length(name_of_place)){
    print(i)
    parking <- bind_rows(
      parking,
      opq(
        bbox = name_of_place[i],
        timeout = 30) %>%
        add_osm_feature(key = 'amenity', 
                        value = 'bicycle_parking') %>%
        osmdata_sf() %>%
        combine_points_polys()
    )
  }
  return(parking)
}

study_cities_bike_parking <- get_bike_parking(study_cities) 

study_cities_bike_parking <- study_cities_bike_parking %>% 
  st_intersection(boundaries)

# visual check
mapview(study_cities_bike_parking)

st_write(study_cities_bike_parking, 
         "data/bicycle_parking_study_cities.gpkg",
         delete_dsn = T)

################################################################################
# Transit stations
################################################################################

get_transit_stations <- function(name_of_place){
  transit <- NULL
  for(i in 1:length(name_of_place)){
    print(i)
    transit <- bind_rows(
      transit,
      opq(
        bbox = name_of_place[i]) %>%
        add_osm_feature(key = 'public_transport', 
                        value = 'station') %>%
        osmdata_sf %>%
        combine_points_polys()
    )
  }
  
  return(transit)
  
}

study_cities_transit <- get_transit_stations(study_cities)

study_cities_transit_filter <- study_cities_transit %>%
  filter(amenity %in% "bus_station" |
         railway %in% "station")

study_cities_transit <- study_cities_transit %>%
  st_intersection(boundaries)

# visual check
mapview(study_cities_transit)

st_write(study_cities_transit,
         "data/study_cities_transit.gpkg")











# for pasting into document
simplify_tags<- function(text){
  text %>%
    str_replace_all("\n  \t", " = ") %>%
    str_replace_all("\n\n\n  ", "\n") %>%
    knitr::kable()
}


# summarize useful tags
study_cities_bike_parking_summary <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  group_by(bicycle_parking) %>%
  summarise(
    count = n()
  ) %>%
  mutate(
    percent = round(100 * count / sum(count), 0)
  )

write_csv(
  study_cities_bike_parking_summary,
  "bicycle_parking_tag_freq.csv"
)

# capacity
bicycle_capacity_summary <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  mutate(
    capacity = as.numeric(capacity),
    capacity_group = case_when(
      capacity <= 2 ~ "2 or less",
      capacity <= 5 ~ "3 to 5",
      capacity <= 10 ~ "6 to 10",
      capacity <= 20 ~ "11 to 20",
      capacity <= 50 ~ "21 to 50",
      capacity > 50 ~ "greater than 50",
      T ~ NA
      
    )) %>%
  group_by(capacity_group) %>%
  summarise(
    count = n()
  ) %>%
  mutate(
    percent = round(100 * count / sum(count), 0)
  )

write_csv(
  bicycle_capacity_summary,
  "bicycle_capacity_summary_freq.csv"
)

# what percent have type and count?
1 - length(which(is.na(study_cities_bike_parking$bicycle_parking) | is.na(study_cities_bike_parking$capacity))) / nrow(study_cities_bike_parking)

# covered
bicycle_covered_summary <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  group_by(covered) %>%
  summarise(
    count = n()
  ) %>%
  mutate(
    percent = round(100 * count / sum(count), 0)
  )

write_csv(
  bicycle_covered_summary,
  "bicycle_covered_summary.csv"
)

# supervised
bicycle_supervised_summary <- study_cities_bike_parking %>%
  st_drop_geometry() %>%
  group_by(supervised) %>%
  summarise(
    count = n()
  ) %>%
  mutate(
    percent = round(100 * count / sum(count), 0)
  )

write_csv(
  bicycle_supervised_summary,
  "bicycle_supervised_summary.csv"
)

# combinations of tags
1 - length(which(is.na(study_cities_bike_parking$bicycle_parking) | is.na(study_cities_bike_parking$capacity) | is.na(study_cities_bike_parking$covered))) / nrow(study_cities_bike_parking)
1 - length(which(is.na(study_cities_bike_parking$bicycle_parking) | is.na(study_cities_bike_parking$capacity) | is.na(study_cities_bike_parking$covered) | is.na(study_cities_bike_parking$supervised))) / nrow(study_cities_bike_parking)
