#!/bin/sh
#SBATCH -e coverage_analyses_%j.err
#SBATCH -o coverage_analyses_%j.out
#SBATCH --job-name=coverage_analyses
#SBATCH --time-min=120:00:00
#SBATCH -c 50
#SBATCH --mem=200G
#SBATCH --partition=highmem
#SBATCH --nodes=1

module load cluster/samtools/1.16.1

# Index the reference genome
minimap2 -d reference.mmi combined_gymnocladusF_assembly.fa

# map the reads
minimap2 -t 50 -ax map-hifi reference.mmi [PATH TO]/m84238_250119_101951_s1.hifi_reads.bc2003.fastq.gz | samtools sort -o aligned_reads.bam

# Index the sorted BAM file
samtools index aligned_reads.bam

# Calculate average coverage
samtools depth aligned_reads.bam | awk '{sum+=$3} END { print "Average Coverage = ",sum/NR}'

###########################################################
###########################################################

module load cluster/samtools/1.16.1

samtools faidx combined_gymnocladusF_assembly.fa

###you are probably going to have to adjust the grep string based on what your chromosomes are called!
cut -f1,2 Suziblue_renamed_reordered.fa.fai | grep -E "Chr\.[0-9]{2}\.[0-9]+" > genome.chrom.sizes

###########################################################
###########################################################

#!/bin/bash
#SBATCH -e new_windows_%j.err
#SBATCH -o new_windows_%j.out
#SBATCH --job-name=new_windows
#SBATCH --time-min=120:00:00
#SBATCH -c 32
#SBATCH --mem=300G
#SBATCH --partition=normal
#SBATCH --nodes=1

module load cluster/bedtools/2.28.0
module load cluster/bwa/0.7.17
module load cluster/samtools/1.16.1

bedtools makewindows -g genome.chrom.sizes -w 300000 -s 100000 > genome_300kb_100kb_sliding_windows.bed

bedtools coverage -a genome_300kb_100kb_sliding_windows.bed -b Suziblue_Final.minimap2.sorted.bam -mean > coverage_300kb_100kb_sliding.bed
