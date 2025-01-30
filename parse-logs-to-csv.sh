#!/bin/bash

# Create or clear the CSV file
output_csv="results.csv"
echo "directory,100 connections,500 connections,1000 connections" > $output_csv

# Find all bombardier-container.log files and process them
find . -name "bombardier-container.log" | while read log_file; do
  # Extract the directory name
  dir_name=$(dirname "$log_file")
  # Extract the 2xx counts using grep and awk
  counts=($(grep -o '2xx - [0-9]\+' "$log_file" | awk '{print $3}'))
  if [ ${#counts[@]} -eq 3 ]; then
    # Append the result to the CSV file
    echo "$dir_name,${counts[0]},${counts[1]},${counts[2]}" >> $output_csv
  fi
done
