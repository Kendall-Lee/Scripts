#!/bin/bash
#SBATCH -J zcat_combine2
#SBATCH --time=96:00:00
#SBATCH -c 2
#SBATCH -N 1
#SBATCH -p plant
#SBATCH -o "stdout_gzip"
#SBATCH -e "stderr_gzip"
#SBATCH --mem="200G"


zcat KSQ0544_2mismatch_S4_L001_R2_001.fastq.gz KSQ0544_S2_L001_R2_001.fastq.gz| gzip > B791_R2.fastq.gz

cat KSQ0544_2mismatch_S4_L001_R2_001.fastq.gz KSQ0544_S2_L001_R2_001.fastq.gz > B791_R2.fastq.gz
