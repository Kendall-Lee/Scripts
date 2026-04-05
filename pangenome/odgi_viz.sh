#!/bin/bash
#SBATCH --job-name=odgi_tubemap
#SBATCH --output=odgi_tubemap.%j.out
#SBATCH --error=odgi_tubemap.%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --partition=normal
ml cluster/vg/1.67.0
# Optional: load conda environment or module
# module load odgi   # if installed as module
# or activate conda env
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/odgi_env

# Set input and output paths
odgi build -g SHB.sv.gfa.fa.gz -o SHB.odgi -t 16 -S seqfile.txt
