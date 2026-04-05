#!/bin/bash
#SBATCH --job-name=bedtools
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=350gb
#SBATCH --time=04:00:00
#SBATCH --output=bedtools.%j.out
#SBATCH --error=bedtools.%j.error

# name variables
# mapping reference
ref='B080_filtered_haps.fasta'
sorted_bam='B080_haps_cifi_aln.sorted.bam'
# prefix for output
pre='B080_haps_CiFi'

ml purge
# load SAMtools
ml cluster/samtools/1.16.1

## first index genome to extract lengths of each chromosome for bedtools
# samtools faidx $ref
## make a text file in the format bedtools wants for -g (which is the chromosome name and its length)
awk '{ print $1"\t"$2 }' $ref.fai > $ref.lengths.txt


## load bedtools
ml cluster/bedtools/2.28.0
## convert the genome to sliding windows (100 kb)
bedtools makewindows -g $ref.lengths.txt -w 100000 -s 90000 > $ref.100kb_windows.bed
## now get mean read mapping depth in those same windows
bedtools coverage -a $ref.100kb_windows.bed -b $sorted_bam -mean > ${pre}.100kb_windows.DEPTH.txt
bedtools coverage -a $ref.100kb_windows.bed -b $sorted_bam > ${pre}.100kb_windows.COV.txt
