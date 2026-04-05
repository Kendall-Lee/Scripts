#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input.panmap> <output.panmap>"
  exit 1
fi

# Input and output file names
input_panmap=$1
output_panmap=$2

# Define the chromosome and region boundaries
chromosome="TRv2Chr.01"
start=12320000
end=12350000

# Use awk to filter the desired region
awk -v chr="$chromosome" -v start="$start" -v end="$end" '
BEGIN {OFS="\t"}
/^#/ || ($1 == chr && $2 >= start && $2 <= end)
' "$input_panmap" > "$output_panmap"

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "Region extracted successfully to $output_panmap"
else
  echo "Failed to extract the region"
  exit 1
fi
