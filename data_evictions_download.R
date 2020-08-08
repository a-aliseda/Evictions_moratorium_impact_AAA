### Coronavirus Resource Center Excercise
## Part II: Data cleaning
## Angel Aliseda Alonso

#install.packages("aws.s3")

# Libraries used to clean the data
library(aws.s3)
library(tidyverse)
library(readxl)

# Download and merge data from The Eviction Lab
  # Matthew Desmond, Ashley Gromis, Lavar Edmonds, James Hendrickson, Katie
  # Krywokulski, Lillian Leung, and Adam Porton. Eviction Lab National Database: Version
  # 1.0. Princeton: Princeton University, 2018, www.evictionlab.org.

# The Eviction Lab has its data uploaded in an AWS S3 bucket named viction-lab-data-downloads  
# Download data from bucket using library aws.s3
# https://cran.r-project.org/web/packages/aws.s3/readme/README.html

states_abb <- c(state.abb, "DC") 

states_path_file <- str_c("eviction-lab-data-downloads/", states_abb) #Create list with all the path files from the bucket
                                                                      #Each path corresponds to a State and the DC
evictions_states <- data.frame()

for (i in seq_along(states_path_file)){
  evictions <- s3read_using(FUN = read.csv, #Get a database for each state using the paths constructed above
                                 bucket = states_path_file[i], 
                                 object = "states.csv")
  
  evictions_states <- rbind(evictions_states, evictions) #Combine all state files into one large dataset
  
} 

# Variables that were removed from the cleaned dataset because they do not provide additional information
summary(evictions_states$parent.location)
summary(evictions_states$low.flag)
summary(evictions_states$imputed)
summary(evictions_states$subbed)

evictions_states_clean <- evictions_states %>% 
  select(-parent.location, -low.flag, -imputed, -subbed)

# Subset of data for the 2016 eviction rate as it is the most recent available value

evictions_states_2016 <- evictions_states_clean %>% 
  filter(year == 2016)

# With this dataset, we can uniderstand characteristics of states with high eviction rates
# AK, AR, ND, SD do not have number of evictions nor eviction rate

# States with the highest eviction rate
evictions_states_2016 %>% 
  arrange(desc(eviction.rate)) %>% 
  select(name, eviction.rate) %>% 
  head()

# States with the lowest eviction rate without states that do not have number of evictions
evictions_states_2016 %>% 
  arrange(desc(eviction.rate)) %>% 
  select(name, eviction.rate) %>%
  filter(!(is.na(eviction.rate))) %>% 
  tail()

# Merge with rental assistance programs database
# The rental assistant programs database was retreived directly from the 
# National Low-Income Housing Coalition website at:
# https://docs.google.com/spreadsheets/d/1hLfybfo9NydIptQu5wghUpKXecimh3gaoqT7LU1JGc8/edit#gid=79194074

# Read the Excel file into R
# First three rows were deleted because they were not part of the database
rental_assistance_df <- read_excel("NLIHC COVID-19 Rental Assistance Database.xlsx",
                                   skip = 3) %>%
  group_by(State) %>% 
  summarize(total_programs = n())

# Check State variable in rental assistance programs dataset to verify it can be used as a key to join it with evictions dataset
table(rental_assistance_df$State)

# Recode "Washington DC" to "District of Columbia" in rental assistance programs dataset
# Rename variable "State" to "name" so that it matches to the evictions dataset
rental_assistance_df <- rental_assistance_df %>% 
  mutate(State = recode(State,
                        `Washington DC` = "District of Columbia")) %>% 
  rename("name" = "State")

# Join the 2016 evictions dataset and the rental assitance programs dataset and
# create a new variable that standardizes the total number of rental assistance programs 
# by total number of renter occupied households

evictions_rental_assistance_states_2016 <- left_join(evictions_states_2016, rental_assistance_df) %>% 
  mutate(total_programs = replace_na(total_programs, 0),
         programs_by_renter_hh = (total_programs/renter.occupied.households)*100000)

# Using this dataset we can start to look at which States have the most and the least 
# rental assistance programs but also states that have the most and the least rental assistant
# programs per 100,000 renter households

# States with highest number of programs
evictions_rental_assistance_states_2016 %>% 
  arrange(desc(total_programs)) %>% 
  select(name, total_programs) %>% 
  head()

# States with lowest number of programs
evictions_rental_assistance_states_2016 %>% 
  arrange(desc(total_programs)) %>% 
  select(name, total_programs) %>% 
  tail()

# States with highest proportion of programs per 100,000 renter households
evictions_rental_assistance_states_2016 %>% 
  arrange(desc(programs_by_renter_hh)) %>% 
  select(name, programs_by_renter_hh) %>% 
  head()

# States with lowest  proportion of programs per 100,000 renter households
evictions_rental_assistance_states_2016 %>% 
  arrange(desc(programs_by_renter_hh)) %>% 
  select(name, programs_by_renter_hh) %>% 
  tail()

# Export the final cleaned datasets to csv
# evictions_2016_clean: includes all variables from Eviction Lab and data from rental assistance programs for 2016
# evictions_2000_2016_clean: only includes variables from Eviction Lab from 2000 to 2016

save(evictions_rental_assistance_states_2016, file = "evictions_2016_clean.csv")
save(evictions_states_clean, file = "evictions_2000_2016_clean.csv")