#!/bin/bash
#SBATCH -J MAGPanRef
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"
###############

ml cluster/gatk/4.0.11.0

gatk CollectReadCounts -I CB7.mapped.IAC322.sam -L list --interval-merging-rule OVERLAPPING_ONLY -O test
