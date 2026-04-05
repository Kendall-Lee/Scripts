#!/bin/bash
#SBATCH --job-name=gzip
#SBATCH -e gzip_%J.err
#SBATCH -o gzip_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=48G
#SBATCH --partition=plant
#SBATCH --array=1-$(wc -l < fastq_list.txt)


# Pick the correct file for this sub‑task
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fastq_list.txt)


# Compress in place
gzip "$FILE"
