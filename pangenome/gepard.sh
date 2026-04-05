#!/bin/bash
#SBATCH --job-name=gepard
#SBATCH --partition=khufu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=200gb
#SBATCH --time=20:00:00
#SBATCH --output=busco2.out
#SBATCH --error=busco2.err



eval "$(conda shell.bash hook)"
conda init
conda activate gepard
