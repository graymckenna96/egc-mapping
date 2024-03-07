# European Green Crab: iNaturalist Data Mapping
# Gray McKenna
# 2024-03-06

# Purpose: explore EGC observations from iNaturalist and generate layers for mapping in ArcGIS Pro

#### LOAD DATA AND LIBRARIES ####

library(tidyverse)
library(maps)

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
#ggsave("./figures/all_observations_by_year.png")

# Most observations are after 2015

# Explore data quality to determine what we will include

obs.grade <- df %>% group_by(quality_grade) %>%
  summarise(n_qual = n())

obs.grade.plot <- ggplot(obs.grade, aes(x=quality_grade, y=n_qual, fill=quality_grade))
obs.grade.plot + geom_bar(stat = "identity") + xlab("Quality Grade") + ylab("N Observations") + theme_bw() +
  scale_fill_manual(values = c("#2FA8A3", "#A32FA8","#a8a32f")) + 
  theme(legend.position = "none")

#ggsave("./figures/all_observations_by_quality.png")

# Most are research grade so we will filter to just research grade observations

df <- df %>% filter(quality_grade == "research")

#### MAP DATA ####

# Filter out any rows with NAs for lat long

df <- df %>% drop_na(latitude, longitude)

# Create layers per year

df_years <- split(df, df$obs_year)

# Start by mapping 1 year just to create initial workflow
#Create a base plot with gpplot2
p <- ggplot() + coord_fixed() +
  xlab("") + ylab("")

#Add map to base plot
base_world <- p + geom_polygon(data=world_map, aes(x=long, y=lat, group=group), 
                                     colour="#ded6ce", fill="#fdfaf7") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
   panel.background = element_rect(fill = '#add3ed', colour = 'white'), 
   axis.line = element_line(colour = "white"), legend.position="none",
   axis.ticks=element_blank(), axis.text.x=element_blank(),
   axis.text.y=element_blank())

# Plot the 2015 observations
ecg_2015 <- base_world + 
  geom_point(data=df_years[['2015']], aes(x=longitude, y=latitude), color="#5f7141", fill="#a8a32f",
             size=4, alpha=I(0.4)) 

ecg_2015
ggsave("./figures/ecg_2015_map.png")

# Crabs are already being observed well outside of native range. Let's check out an earlier year.

ecg_2005 <- base_world + 
  geom_point(data=df_years[['2005']], aes(x=longitude, y=latitude), color="#2FA8A3", fill="#2FA8A3",
             size=4, alpha=I(0.4)) 

ecg_2005
ggsave("./figures/ecg_2005_map.png")

# Crabs present in new england, US, but still mostly in Europe

# Let's look at 2023 distribution 
ecg_2023 <- base_world + 
  geom_point(data=df_years[['2023']], aes(x=longitude, y=latitude), color="#A32FA8", fill="#A32FA8",
             size=4, alpha=I(0.2)) 

ecg_2023
ggsave("./figures/ecg_2023_map.png")

# Wow, many crab
