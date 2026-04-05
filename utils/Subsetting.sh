#!/bin/bash
#SBATCH -J subsample
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 2
#SBATCH -p khufu
#SBATCH -o stdout_sub
#SBATCH -e stderr_sub
#SBATCH --mem="200G"


#for subsampling
#assigning the variable actuallength to a command that removes the headers from the reference fasta file then counts all the characters to get the length
actuallength=$(cat /cluster/home/klee/PacBio_project/ref.fa | grep -v ">" | awk '{X=X+length($0)} END {print X}')
#assign fq to the file name
fq="WG3-62_hifi_reads.bc2049.fastq.gz"
#count how many lines are need to get to the genome lengthcd
len=$(zcat $fq | awk '{if (NR%4==2){print length($0)}}' | awk -v Y=$(echo "scale=0; $actuallength * 0.25" | bc) '{X=$0+X;if (X>=Y){print NR*4}}'| head -1)
#move those lines found in previous code to a new file- this si the subset
zcat $fq | head -"$len" | gzip > WG3-62_hifi_reads.bc2049.25x.fastq.gz





# For subsampling
# Assign the variable actualLength to a command that removes the headers from the reference fasta file and then counts all the characters to get the length
actualLength=$(cat /cluster/home/klee/PacBio_project/ref.fa | grep -v ">" | awk '{X=X+length($0)} END {print X}')
# Assign fq to the file name
fq="florida07.fa"
# Calculate the target length for 0.9x coverage
targetLength=$(echo "scale=0; $actualLength * 0.9" | bc)
# Count how many lines are needed to reach the target genome length
len=$(zcat $fq | awk '{if (NR%4==2){print length($0)}}' | awk -v Y=$targetLength '{X=$0+X;if (X>=Y){print NR*4}}' | head -1)
# Move those lines found in the previous code to a new file - this is the subset
zcat $fq | head -"$len" | gzip > Justin2023-FA-CW-W2-F2-15_hifi_reads.bc2009.subsample.fastq.gzllll
