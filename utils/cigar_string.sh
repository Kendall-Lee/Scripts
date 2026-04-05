#!/bin/bash

# Function to calculate aligned length from CIGAR string
calculate_aligned_length() {
    local CIGAR=$1
    local ALIGNED_LENGTH=0

    # Extracting numbers and operations from CIGAR string
    while [[ $CIGAR =~ ([0-9]+)([MIDSH]) ]]; do
        LENGTH=${BASH_REMATCH[1]}
        OPERATION=${BASH_REMATCH[2]}

        case $OPERATION in
            M | I | S)
                ((ALIGNED_LENGTH += LENGTH))
                ;;
        esac

        # Remove processed part of CIGAR string
        CIGAR=${CIGAR#*"${BASH_REMATCH[0]}"}
    done

    echo $ALIGNED_LENGTH
}

# Read CIGAR strings from SAM file
SAM_FILE="joellecontigs_co46_minimap.sam"

# Process each line in the SAM file
while IFS= read -r line; do
    # Extract CIGAR string from SAM line
    CIGAR_STRING=$(echo "$line" | awk '{print $6}')

    # Calculate aligned length
    TOTAL_ALIGNED_LENGTH=$(calculate_aligned_length "$CIGAR_STRING")

    # Print results
    echo "CIGAR String: $CIGAR_STRING, Total Aligned Length: $TOTAL_ALIGNED_LENGTH"
done < "$SAM_FILE"





###################################################################################
#to just extract the cigar string from a sam files

#!/bin/bash

# Replace 'joellecontigs_co46_minimap.sam' with your actual SAM file name
sam_file="joellecontigs_co46_minimap.sam"

# Use awk to extract the CIGAR string (column 6 in SAM format)
cigar_string=$(awk '{if ($1 !~ /^@/) print $6}' "$sam_file")

echo "$cigar_string"
