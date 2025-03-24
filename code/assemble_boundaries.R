library(mapview)
library(sf)
library(tidyverse)

# set the study area boundaries

target.projection <- 3348 # stats can albers

# get polygons for clip
cma_boundaries <- st_read("data/census_boundaries/cma/lcma000b21a_e.shp") %>%
  filter(CMANAME %in% c("Vancouver",
                        "Victoria")) %>%
  st_transform(target.projection) %>%
  group_by(CMANAME) %>%
  summarise() %>%
  rename(name = CMANAME)

montreal_island_csd_uids <- c(
  "2466007", "2466023", "2466032", "2466047", "2466058", "2466062", "2466072",
  "2466087", "2466097", "2466102", "2466107", "2466112", "2466117", "2466127",
  "2466142"
)

# other boundaries
boundaries <- st_read("data/census_boundaries/csd/lcsd000b21a_e.shp") %>%
  filter(CSDNAME %in% c("Calgary",
                        "Toronto",
                        "Kingston",
                        "Guelph",
                        "Saskatoon",
                        "Halifax") &
           CSDTYPE %in% c("CY", "C", "RGM") |
           CSDUID %in% montreal_island_csd_uids) %>%
  mutate(CSDNAME = case_when(
    CSDUID %in% montreal_island_csd_uids ~ "Island of Montreal",
    T ~ CSDNAME)) %>%
  group_by(CSDNAME) %>%
  summarise() %>%
  rename(name = CSDNAME) %>%
  st_transform(target.projection) %>%
  rbind(cma_boundaries)

# visual check
mapview(boundaries)

st_write(boundaries,
         "data/boundaries.gpkg",
         delete_dsn = T)
