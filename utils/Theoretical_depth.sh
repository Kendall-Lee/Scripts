#!/bin/bash

# Usage:
#   ./calc_depth.sh reference.fa *.fasta
#
# Computes total base pairs from each FASTA and coverage depth
# relative to the reference genome.

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 reference.fa sample1.fasta [sample2.fasta ...]"
    exit 1
fi

REF=$1
shift

# --- Calculate genome size ---
echo "Calculating reference genome size..."
GENOME_SIZE=$(awk '/^>/ {next} {bp += length($0)} END {print bp}' "$REF")
echo "Reference genome size = $GENOME_SIZE bp"
echo

# --- Header ---
printf "%-40s %-15s %-15s\n" "Sample" "TotalBases(bp)" "Depth(x)"
printf "%-40s %-15s %-15s\n" "------" "--------------" "--------"

# --- Loop through FASTA files ---
for FASTA in "$@"; do
    SAMPLE=$(basename "$FASTA")
    TOTAL_BASES=$(awk '/^>/ {next} {bp += length($0)} END {print bp}' "$FASTA")
    DEPTH=$(awk -v tb="$TOTAL_BASES" -v gs="$GENOME_SIZE" 'BEGIN {printf "%.2f", tb/gs}')
    printf "%-40s %-15s %-15s\n" "$SAMPLE" "$TOTAL_BASES" "$DEPTH"
done
