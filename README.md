# OSM Can-PARK

## Project description

OSM Can-PARK applies [Can-PARK](https://www.dropbox.com/scl/fi/mr96uegwa28x5hs1h6fia/Can-PARK-Report-04APR2024-1.pdf?rlkey=gsedqkvcr5efsw9sa2yatqi89&st=hcvkssgs&dl=0) 
labels to [OpenStreetMap(OSM)](https://www.openstreetmap.org) data.


[Can-PARK](https://www.dropbox.com/scl/fi/mr96uegwa28x5hs1h6fia/Can-PARK-Report-04APR2024-1.pdf?rlkey=gsedqkvcr5efsw9sa2yatqi89&st=hcvkssgs&dl=0) 
is a functional classification framework for bicycle parking facilities. In this project, [OpenStreetMap(OSM)](https://www.openstreetmap.org), the volunteered 
streetmap of the world, was used as a single unified database. In this project, 
we modified the Can-PARK labels slightly, to make the best use of the data 
available on OSM. OSM Can-PARK classes are given in the data section below.

**This project is experimental and we can not guarantee the accuracy of the 
results.** 

OSM is constantly being edited and updated, so the results will change over time.

Our intent is to explore the potential benefits and challenges of 
using OSM to inventory bicycle parking facilities and demonstrate considerations
for building a central bicycle parking database. Our focus was to measure high
quality bicycle parking near transit stations.

## Data
The datasets created for this project are available in the following spatial 
format files, from data acquired on March 24, 2025:

* [bike_parking_24March2025.gpkg](https://www.dropbox.com/scl/fi/xil05wcxke7sf4k812phf/bike_parking_24March2025.gpkg?rlkey=q24qmsgi60lljezr7qilps6z0&dl=0) 
(2.6 MB) Can-PARK classification of OSM data.
* [bike_parking_full_24March2025.gpkg](https://www.dropbox.com/scl/fi/5d97nz29e6ie37isvf469/bike_parking_full_24March2025.gpkg?rlkey=hfh71di5c5pormgvtzgd7lgt9&dl=0) 
(4.5 MB) Can-PARK classification of OSM data with all OSM tags.
* [transit_station_buffers_24March2025.gpkg](https://www.dropbox.com/scl/fi/usgqfpodl5x8k7v40xirk/transit_station_buffers_24March2025.gpkg?rlkey=u0g6ju78ckdaomce0ywb00rmp&dl=0) 
(2.7 MB) Buffers (125m) of transit stations used in analyses.

**Attributes**

* **osm_id** Unique id on OpenStreetMap. Note that these can change over time.
* **name** Name from OpenStreetMap (optional).
* **description** Description from OpenStreetMap (optional).
* **can_park_class** 
  * 1L: Long-term, lockers.
  *	1S: Long-term, secure.
  *	2U: Short-term, bike racks, no cover, or cover unknown.
  *	2C: Short-term, bike racks, covered.
  *	3V: Bike valet.
* **near_transit_hub** True/False - within 125 m of a transit station.
* **place** Study area name.

Other fields are from OSM - please search the [OSM wiki](https://wiki.openstreetmap.org/wiki/Main_Page) for 
documentation.

## How to run the project

This project is structured to run within an [RStudio project](https://posit.co/download/rstudio-desktop/).
To run this project, install RStudio and packages within the code section.

### Code

Requires the R scripts to be run in the following sequential order:

* **assemble_boundaries.R** Uses 2021 Statistics Canada Boundary files to create
polygon boundaries for the study area. Requires 
[Canada Census CSD and CMA Boundary files](https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21), 
located in the data folder.
* **dowload_osm.R** Downloads OSM features related to bike parking and transit 
stations.
* **assign_can_park.R** Assign OSM Can-PARK labels (classify).
* **intersect_transit.R** Intersect bike parking with transit.
* **summary_reporting.R** Counts and percent composition: overall and by study 
city; city-wide and near-transit.
* **graph.R** Create graph.
* **export.R** Export data for sharing.


### Use and sharing

Data by OpenStreetMap contributors (2025) is open data licensed under the Open 
Data Commons Open Database License (ODbL). Under this license, You are free to 
copy, distribute, transmit and adapt our data, as long as you credit 
OpenStreetMap and its contributors. If you alter or build upon our data, you may 
distribute the result only under the same licence.

### Contact
Colin Ferster colin_ferster_2@sfu.ca
