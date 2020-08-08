# Exploring the impact of expiring moratoriums in cities README
## Angel Aliseda Alonso

This repository contains the files and first exploration analysis for the impact of expiring moratoriums in cities.

Data was downloaded from The Eviction Lab:
 + Matthew Desmond, Ashley Gromis, Lavar Edmonds, James Hendrickson, Katie, Krywokulski, Lillian Leung, and Adam Porton. Eviction Lab National Database: Version 1.0. Princeton: Princeton University, 2018, www.evictionlab.org. 

This repository contains the following files:
 + [data_evictions_download.R](data_evictions_download.R): R Script with all the necessary code needed to clean and produce the databases.
 + [evictions_part1_Angel_Aliseda.pdf](evictions_part1_Angel_Aliseda.pdf): answer to Excercise Part I
 + [evictions_part1_Angel_Aliseda.pdf](evictions_part1_Angel_Aliseda.pdf): RMarkdown file needed to produce PDF file
 + [NLIHC COVID-19 Rental Assistance Database.xlsx](NLIHC COVID-19 Rental Assistance Database.xlsx): database with Rental Assistance Programs from the National Low-Income Housing Coalition website
 + [evictions_2016_clean](evictions_2016_clean): dataset that includes all variables from Eviction Lab and data from rental assistance programs for 2016
 + [evictions_2000_2016_clean](evictions_2000_2016_clean): dataset that only includes variables from Eviction Lab from 2000 to 2016
 
The libraries needed to clean the data are:
 + library(aws.s3)
 + library(readxl)
