# Bulk add layers to map in ArcGIS Pro

# Note: copy and paste annual csvs output from ecg_data_prep.R script to a Pro project

import arcpy
import os

arcpy.env.workspace = r"C:\Users\graym\Documents\ArcGIS\Projects\EuropeanGreenCrab"

# save wd to a variable
wd = "C:\\Users\\graym\\Documents\\ArcGIS\\Projects\\EuropeanGreenCrab\\"

# List all the csv files in the workspace
csv_list = arcpy.ListFiles("*.csv")

# Loop through and add all to map 
for i in csv_list:
    arcpy.management.XYTableToPoint(wd + i, i, "longitude", "latitude")
