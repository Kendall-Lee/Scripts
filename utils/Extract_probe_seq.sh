#!/bin/bash

PROBE_COORDS=probes.txt   # your coordinates file
REFERENCE=reference.fasta # your input fasta
OUTPUT=probes_extracted.fasta

# Index the FASTA for fast random access
samtools faidx $REFERENCE

# Empty output file
> $OUTPUT

# Loop through each probe coordinate line
while read line; do
    id=$(echo $line | cut -d' ' -f1 | cut -d':' -f1)   # e.g. AA556154.1
    start=$(echo $line | awk '{print $2+1}')           # convert 0-based to samtools 1-based
    end=$(echo $line | awk '{print $3}')               # end is already exclusive upper bound

    # Extract the subsequence
    seq=$(samtools faidx $REFERENCE ${id}:${start}-${end} | grep -v '^>')

    # Write with probe name
    echo ">$line" >> $OUTPUT
    echo $seq >> $OUTPUT
done < $PROBE_COORDS
