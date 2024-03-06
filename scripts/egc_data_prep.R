# European Green Crab: iNaturalist Data Mapping
# Gray McKenna
# 2024-03-06

# Purpose: explore EGC observations from iNaturalist and generate layers for mapping in ArcGIS Pro

#### LOAD DATA AND LIBRARIES ####

library(tidyverse)
library(sf)

df <- read.csv("./data/observations-408160.csv")

#### EXPLORE DATA ####

str(df)
head(df)

# Reformat date col
df$obs_date <- as.Date(df$observed_on, "%Y-%m-%d")

# Create year col 
df$obs_year <- lubridate::year(df$obs_date)

# Drop cols with NAs for observed_on - if there's no observation date, we don't want to use the data
df <- df %>% drop_na(observed_on)

# View observations by year
obs.year <- df %>% group_by(obs_year) %>%
  summarise(n_obs = n())

obs.year.plot <- ggplot(obs.year, aes(x=obs_year, y=n_obs))
obs.year.plot + geom_bar(stat="identity", fill="#a8a32f") + 
  geom_point(color="#5f7141") +
  theme_bw() +
  xlab("Year") +
  ylab("Total Observations")
ggsave("./figures/all_observations_by_year.png")

# Most observations are after 2015

# Explore data quality to determine what we will include

obs.grade <- df %>% group_by(quality_grade) %>%
  summarise(n_qual = n())

obs.grade.plot <- ggplot(obs.grade, aes(x=quality_grade, y=n_qual, fill=quality_grade))
obs.grade.plot + geom_bar(stat = "identity") + xlab("Quality Grade") + ylab("N Observations") + theme_bw() +
  scale_fill_manual(values = c("#2FA8A3", "#A32FA8","#a8a32f")) + 
  theme(legend.position = "none")

ggsave("./figures/all_observations_by_quality.png")

# Most are research grade so we will filter to just research grade observations

df <- df %>% filter(quality_grade == "research")

#### MAP DATA ####

# Create layers per year

df_years <- split(df, df$obs_year)
