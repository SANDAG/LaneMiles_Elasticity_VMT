
library(tidycensus)
library(tidyverse)

census_api_key("dd112481fc56e9d8e75a025ad878176c63a05c7a", install = FALSE)

# 2000 Decennial (SF3) – Employment, Education, Poverty, Median Household Income
vars_2000 <- c(
  labor_force = "P043001",
  employed =   "P043003",
  unemployed = "P043005",
  
  edu_total_25plus = "P037001",
  edu_bachelors =   "P037015",
  edu_graduate =    "P037016",
  
  poverty_universe = "P087001",
  poverty_below =    "P087002",
  
  median_household_income = "H063001",   # Correct SF3 median household income variable,
  population = "P001001"
)

d2000 <- get_decennial(
  geography = "county",
  variables = vars_2000,
  year = 2000,
  sumfile = "sf3",
  state = "CA"
) %>%
  pivot_wider(names_from = variable, values_from = value) %>%
  mutate(
    unemployment_rate = unemployed / labor_force,
    poverty_rate = poverty_below / poverty_universe,
    bachelors_plus_rate = (edu_bachelors + edu_graduate) / edu_total_25plus,
    year = 2000
  )

# Variables for 2013 ACS
vars_2013 <- c(
  labor_force = "B23025_002",
  unemployed = "B23025_005",
  
  edu_total_25plus = "B15003_001",
  edu_bachelors = "B15003_022",
  edu_graduate = "B15003_023",
  
  poverty_universe = "B17001_001",
  poverty_below = "B17001_002",
  
  median_household_income = "B19013_001",
  population = "B01003_001" 
)

d2013 <- get_acs(
  geography = "county",
  variables = vars_2013,
  year = 2013,
  survey = "acs5",
  state = "CA"
) %>%
  select(-moe) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    unemployment_rate = unemployed / labor_force,
    poverty_rate = poverty_below / poverty_universe,
    bachelors_plus_rate = (edu_bachelors + edu_graduate) / edu_total_25plus,
    year = 2013
  )

# Variables for 2023 ACS
vars_2023 <- c(
  labor_force = "B23025_002",
  unemployed = "B23025_005",
  
  edu_total_25plus = "B15003_001",
  edu_bachelors = "B15003_022",
  edu_graduate = "B15003_023",
  
  poverty_universe = "B17001_001",
  poverty_below = "B17001_002",
  
  median_household_income = "B19013_001",
  population = "B01003_001" 
)

d2023 <- get_acs(
  geography = "county",
  variables = vars_2023,
  year = 2023,
  survey = "acs5",
  state = "CA"
) %>%
  select(-moe) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    unemployment_rate = unemployed / labor_force,
    poverty_rate = poverty_below / poverty_universe,
    bachelors_plus_rate = (edu_bachelors + edu_graduate) / edu_total_25plus,
    year = 2023
  )


clean_tc <- function(df, yr) {
  df %>%
    select(
      GEOID,
      NAME,
      population,
      edu_total_25plus,
      edu_bachelors,
      edu_graduate,
      labor_force,
      unemployed,
      poverty_universe,
      poverty_below,
      median_household_income,
      unemployment_rate,
      poverty_rate,
      bachelors_plus_rate
    ) %>%
    mutate(year = yr)
}

d2000_clean <- clean_tc(d2000, 2003)
d2013_clean <- clean_tc(d2013, 2013)
d2023_clean <- clean_tc(d2023, 2023)

panel <- bind_rows(
  d2000_clean,
  d2013_clean,
  d2023_clean
)

panel$GEOID <- as.integer(panel$GEOID)

panel <- panel %>% 
  mutate(ct_yr = paste(GEOID, year, sep = "-"))

path_out <- "2_Data Cleaning//Code_Output"
write.csv(panel, file.path(path_out, "ca_acs_ct_03_23.csv"), row.names=FALSE)



#IPUMS NHCGS
setwd("C:/Users/afr/OneDrive - San Diego Association of Governments/Data Science - Documents/Economics/FY2026_27 Projects/Misc Projects/Elasticity of Lane Miles")

data_2000_1990_1980 <- read.csv("1_Source Data/IPUMS/nhgis0002_ts_nominal_county.csv")

data_2000_1990_1980$COUNTYNH <- data_2000_1990_1980$COUNTYNH / 10

names(data_2000_1990_1980)

data_2000_1990_1980_clean <- data_2000_1990_1980 %>%
  transmute(
    fips = COUNTYNH + 6000,
    year = YEAR,
    county_name = NAME,
    population = AV0AA,
    edu_total_25plus = B69AA,
    edu_bachelors = B69AB,
    edu_graduate = B69AC,
    # B84AC is the actual Civilian Labor Force (Employed + Unemployed)
    civilian_labor_force = B84AC, 
    # B84AD is the count of Employed civilians
    employed = B84AD,             
    unemployed = B84AE,
    poverty_universe = AX6AA,
    poverty_below = CL6AA
  ) %>%
  mutate(
    # Corrected denominator: Unemployed divided by Civilian Labor Force
    unemployment_rate = unemployed / civilian_labor_force, 
    poverty_rate = poverty_below / poverty_universe,
    bachelors_plus_rate = (edu_bachelors + edu_graduate) / edu_total_25plus
  )



data_2000_1990_1980_income <- read.csv("1_Source Data/IPUMS/nhgis0003_ts_nominal_county.csv")

data_2000_1990_1980_income$COUNTYNH <- data_2000_1990_1980_income$COUNTYNH / 10

data_2000_1990_1980_income <- data_2000_1990_1980_income %>%
  transmute(
    fips = COUNTYNH + 6000,
    county_name = NAME,
    year = YEAR,
    median_household_income = B79AA
  )


data_2000_1990_1980_clean <- data_2000_1990_1980_clean %>% 
  mutate(ct_yr = paste(fips, year+3, sep = "-"))

data_2000_1990_1980_income <- data_2000_1990_1980_income %>% 
  mutate(ct_yr = paste(fips, year+3, sep = "-")) %>%
  select(-fips, -county_name, -year)

data_2000_1990_1980_clean <- data_2000_1990_1980_clean %>% 
  left_join(data_2000_1990_1980_income, by = "ct_yr")

data_1990_1980_clean <- data_2000_1990_1980_clean %>%
  filter(year < 2000)

path_out <- "2_Data Cleaning//Code_Output"
write.csv(data_1990_1980_clean, file.path(path_out, "ca_acs_ct_83_93.csv"), row.names=FALSE)








 