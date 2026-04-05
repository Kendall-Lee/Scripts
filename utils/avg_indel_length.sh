#!/bin/bash

# Header for the output
echo -e "File\tAverage Insertion Length\tAverage Deletion Length" > sv_avg_lengths.tsv

# Loop through each VCF file
for vcf_file in ./*.vcf; do
  # Extract the lengths of insertions and deletions
  insertions=$(grep "SVTYPE=INS" "$vcf_file" | grep -o "SVLEN=[0-9]*" | cut -d'=' -f2)
  deletions=$(grep "SVTYPE=DEL" "$vcf_file" | grep -o "SVLEN=-[0-9]*" | cut -d'=' -f2 | tr -d '-')

  # Calculate the average insertion length
  if [ -n "$insertions" ]; then
    total_ins_len=$(echo "$insertions" | awk '{sum+=$1} END {print sum}')
    count_ins=$(echo "$insertions" | wc -l)
    avg_ins_len=$(echo "scale=2; $total_ins_len / $count_ins" | bc)
  else
    avg_ins_len=0
  fi

  # Calculate the average deletion length
  if [ -n "$deletions" ]; then
    total_del_len=$(echo "$deletions" | awk '{sum+=$1} END {print sum}')
    count_del=$(echo "$deletions" | wc -l)
    avg_del_len=$(echo "scale=2; $total_del_len / $count_del" | bc)
  else
    avg_del_len=0
  fi

  # Write the averages to the output file
  echo -e "$(basename "$vcf_file")\t$avg_ins_len\t$avg_del_len" >> sv_avg_lengths.tsv
done

echo "Average insertion and deletion lengths have been written to sv_avg_lengths.tsv"
