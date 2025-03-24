library(scales)
library(tidyverse)
library(ggplot2)

options(scipen=999)

# create a graph of composition
bike_parking <- read_csv("data/overall_summary.csv")

bike_parking <- bike_parking %>%
  mutate(
    place = str_replace(place,
                        "Vancouver",
                        "Metro Vancouver"),
    place = str_replace(place,
                        "Victoria",
                        "Greater Victoria"),
    place = factor(place,
                   levels = c(
                     "All study cities",
                     "Halifax",
                     "Island of Montreal",
                     "Kingston",
                     "Toronto",
                     "Guelph",
                     "Saskatoon",
                     "Calgary",
                     "Metro Vancouver",
                     "Greater Victoria"
                   )),
    can_park_class_original = can_park_class,
    can_park_class = case_when(can_park_class %in% "1S: Long-term, secure" ~ "Class 1S",
                               can_park_class %in% "1L: Long-term, lockers" ~ "Class 1L",
                               can_park_class %in% "2C: Short-term, bike racks, covered" ~ "Class 2C",
                               can_park_class %in% "2U: Short-term, bike racks, no cover, or cover unknown" ~ "Class 2U",
                               can_park_class %in% "3V: Bike valet" ~ "Class 3V"),
    can_park_class = factor(can_park_class,
                            levels = c(
                              "Class 1S",
                              "Class 1L",
                              "Class 2C",
                              "Class 2U",
                              "Class 3V" 
                              # if present in the future, add corrals here
                            )),
    label_text = scales::percent(percent, accuracy = 1),
    label_text = ifelse(label_text %in% "0%", "", label_text))

parking_composition_plot <- bike_parking %>%
  mutate('Can-PARK class' = can_park_class) %>%
  ggplot(aes(x = place,
             y = percent,
             fill = `Can-PARK class`)) + 
  geom_bar(stat = "identity",
           position = "stack") +
  scale_fill_manual(values = c("#33a02c","#b2df8a","#1f78b4","#a6cee3","#6a3d9a")) + # if present in the future, add corrals here
  geom_text(aes(
    y = (percent),
    label = label_text),
    colour = "white",
    fontface = "bold",
    size = 2.5,
    angle = 0,
    vjust = 0.5,
    hjust = 0.5,
    position = position_stack(vjust = 0.5)) +
  facet_grid(location ~ .) +
  theme_minimal() +
  theme(axis.title.x=element_blank(),
        axis.text.y = element_blank(),
        text = element_text(family = "Helvetica", size = 12),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# note: edit in Inskape to make overlapping labels clear and add overall counts
# delete 3V - not visible on graph
ggsave(
  "figures/parking_composition_plot.pdf",
  parking_composition_plot,
  width = 180,
  height = 90,
  units = "mm",
  dpi = 300)


# get the counts by city
bike_parking %>%
  group_by(place, location) %>%
  summarise(count = sum(count))

# get the counts by city and type
bike_parking %>%
  group_by(place, location, can_park_class) %>%
  summarise(count = sum(count)) %>%
  View()
