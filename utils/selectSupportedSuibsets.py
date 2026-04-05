#!/bin/bash
#SBATCH --job-name=braker
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=90gb
#SBATCH --time=99:00:00
#SBATCH --output=braker.out
#SBATCH --error=braker.err
#SBATCH --mail-user=kcl58759@uga.edu
#SBATCH --mail-type=END,FAIL

ml BRAKER/12212020-foss-2019b-Perl-5.30.0-Python-3.7.4
cd ./
export AUGUSTUS_CONFIG_PATH=/home/kcl58759/config_augustus

selectSupportedSubsets.py 
