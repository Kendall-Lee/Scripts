#!/bin/bash
#SBATCH --job-name=Rscript
#SBATCH -e Rscript.R_%J.err
#SBATCH -o Rscript.R_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=normal


module load r/4.4.1-gcc-13.1.0

Rscript vcf2dosage.R
