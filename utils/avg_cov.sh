#!/bin/bash

# Directory containing your *_samtools_coverage.txt files

# Loop through each *_samtools_coverage.txt file
for file in ./*_samtools_coverage.txt; do
    echo "Processing $file:"
    average=$(tail -n +2 "$file" | awk '{ total += $6; count++ } END { if (count > 0) print total/count; else print "No data" }')
    echo "Average of column 6: $average"
    echo  # Add an empty line for separation
done





########save output as txt file then run this to copy to excel ######
#!/bin/bash

# Input file
input_file="Filtered_SR_cov.txt"

# Process the file and output in tab-separated format
awk '
/Processing/ {
    # Extract the base filename (remove the path and extension)
    split($2, arr, "/");
    split(arr[length(arr)], base, "_short_samtools_coverage.txt");
    filename = base[1];
}
/Average/ {
    avg = $5;
    print filename "\t" avg;  # Use tab separator
}' "$input_file"
