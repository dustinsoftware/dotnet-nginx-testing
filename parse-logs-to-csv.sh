#!/bin/bash

# Create or clear the CSV files
output_csv_2xx="results_2xx.csv"
output_csv_5xx="results_5xx.csv"
echo "directory,100 connections,500 connections,1000 connections,2000 connections" > $output_csv_2xx
echo "directory,100 connections,500 connections,1000 connections,2000 connections" > $output_csv_5xx

# Find all bombardier-container.log files and process them
find . -name "bombardier-container.log" | while read log_file; do
  # Extract the directory name
  dir_name=$(dirname "$log_file")
  # Extract the 2xx and 5xx counts using grep and awk
  counts_2xx=($(grep -o '2xx - [0-9]\+' "$log_file" | awk '{print $3}'))
  counts_5xx=($(grep -o '5xx - [0-9]\+' "$log_file" | awk '{print $3}'))
  if [ ${#counts_2xx[@]} -eq 4 ]; then
    # Append the 2xx result to the CSV file
    echo "$dir_name,${counts_2xx[0]},${counts_2xx[1]},${counts_2xx[2]},${counts_2xx[3]}" >> $output_csv_2xx
  fi
  if [ ${#counts_5xx[@]} -eq 4 ]; then
    # Append the 5xx result to the CSV file
    echo "$dir_name,${counts_5xx[0]},${counts_5xx[1]},${counts_5xx[2]},${counts_5xx[3]}" >> $output_csv_5xx
  fi
done

# Convert the CSV files to Markdown
markdown_file="results.md"
echo "# Load test results" > $markdown_file
echo "## 2xx Results" >> $markdown_file
echo "| Directory | 100 connections | 500 connections | 1000 connections | 2000 connections |" >> $markdown_file
echo "|-----------|-----------------|-----------------|------------------|------------------|" >> $markdown_file
tail -n +2 $output_csv_2xx | while IFS=, read -r directory c100 c500 c1000 c2000; do
    echo "| $directory | $c100 | $c500 | $c1000 | $c2000 |" >> $markdown_file
done

echo "" >> $markdown_file
echo "## 5xx Results" >> $markdown_file
echo "| Directory | 100 connections | 500 connections | 1000 connections | 2000 connections |" >> $markdown_file
echo "|-----------|-----------------|-----------------|------------------|------------------|" >> $markdown_file
tail -n +2 $output_csv_5xx | while IFS=, read -r directory c100 c500 c1000 c2000; do
    echo "| $directory | $c100 | $c500 | $c1000 | $c2000 |" >> $markdown_file
done

# Copy the markdown file to the GitHub step summary
cp $markdown_file $GITHUB_STEP_SUMMARY
