#!/bin/bash
#SBATCH --job-name=gwaspoly
#SBATCH --output=gwaspoly_%j.out
#SBATCH --error=gwaspoly_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=4

# If your cluster uses environment modules
module load r/4.4.1-gcc-13.1.0   # or whichever version is available

# Activate conda if you used conda for GWASpoly
# source ~/miniconda3/etc/profile.d/conda.sh
# conda activate r-env
Rscript vcf2dosage.R
# Run your R script
Rscript gwaspoly.R
