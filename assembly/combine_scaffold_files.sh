#!/bin/bash
#SBATCH -J combine_scaffolds
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"
###############

cat *fasta | awk '/^>/{flag=0; next;} {printf $1} END {print ""}' > VaccDscaffcombined.fasta
