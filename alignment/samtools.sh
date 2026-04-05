#!/bin/bash
#SBATCH --job-name=samtools
#SBATCH -e bwa_%J.err
#SBATCH -o bwa_%J.out
#SBATCH --time=72:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=40
#SBATCH --mem=320G
#SBATCH --partition=plant

module load cluster/samtools/1.16.1


samtools faidx Suziblue_allruns.fastq
