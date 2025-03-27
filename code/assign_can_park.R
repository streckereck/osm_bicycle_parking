library(mapview)
library(sf)
library(tidyverse)

# for debugging set to T 
visual_checks <- F

study_cities_bike_parking <- st_read("data/bicycle_parking_study_cities.gpkg")

# assign attributes using logical statements
study_cities_bike_parking <- study_cities_bike_parking %>%
  mutate(
    lockers = bicycle_parking %in% "lockers" | grepl("locker", name, ignore.case = T) | grepl("locker", description, ignore.case = T),
    cover = covered %in% c("yes", "roof", "partial") | bicycle_parking %in% c("building", "shed", "lockers") | indoor %in% "yes" | lockers,
    secured = fee %in% c("yes") | ! is.na(charge) | ! is.na(opening_hours) | supervised %in% "yes" | lockers,
    valet = bicycle_parking %in% "valet" | grepl("valet", name, ignore.case = T) | grepl("valet", description, ignore.case = T) | grepl("valet", operator, ignore.case = T),
    corral = bicycle_parking %in% "corall" | grepl("corall", name, ignore.case = T) | grepl("corall", description, ignore.case = T) | grepl("corall", operator, ignore.case = T))

# visual checks
if(visual_checks){
  # tables
  View(study_cities_bike_parking[, c("bicycle_parking", "name", "lockers")])
  View(study_cities_bike_parking[, c("bicycle_parking", "name", "covered", "cover")])
  View(study_cities_bike_parking[, c("bicycle_parking", "name", "secured")])
  View(study_cities_bike_parking[, c("bicycle_parking", "name", "description", "valet", "corral")])
  
  # maps
  mapview(study_cities_bike_parking)
}


# assign can-park class
# note that Can-PARK assignment is sequential from top to bottom - so the first
# condition that is met is assigned

study_cities_bike_parking <- study_cities_bike_parking %>%
  mutate(can_park_class = case_when(
    valet ~ "3V: Bike valet",
    lockers ~ "1L: Long-term, lockers",
    cover & secured ~ "1S: Long-term, secure",
    corral | cover ~ "2C: Short-term, bike racks, covered",
    T ~ "2U: Short-term, bike racks, no cover, or cover unknown"
  ))

if(visual_checks){
  View(study_cities_bike_parking[, c("bicycle_parking", "name", "cover", "secured", "can_park_class")])
}

st_write(study_cities_bike_parking,
         "data/bicycle_parking_study_cities.gpkg",
         delete_dsn = T)
