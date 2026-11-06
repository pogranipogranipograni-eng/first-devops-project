#!/bin/bash

path_to_compute="$1"

directory="${path_to_compute%/*}"
echo "Directory with path: $directory"

file_name="${path_to_compute##*/}"
echo "File name: $file_name"

no_extention_file_name="${file_name%.*}"
echo "No extention file name: $no_extention_file_name"

service="${no_extention_file_name%%_*}"
echo "Service: $service"

env_with_date="${no_extention_file_name#*_}"
env="${env_with_date%_*}"
echo "Environment: $env"

full_date="${env_with_date#*_}"
echo "full date: $full_date"

year="${full_date%%-*}"
echo "Year of log occurence: $year"

month_with_day="${full_date#*-}"
month="${month_with_day%-*}"
echo "Month of log occurence: $month"

echo "File name with capital laters: ${file_name^^}"
