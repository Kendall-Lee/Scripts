#!/bin/bash
#SBATCH -J samtools_tabix
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_samtools_tabix
#SBATCH -e stderr_samtools_tabix
#SBATCH --mem="90G"


cluster/samtools/1.16.1


tabix -p C76_16_HIFI_subsample.vcf
