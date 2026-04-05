#!/bin/bash
#SBATCH --job-name=Circos
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=90gb
#SBATCH --time=99:00:00
#SBATCH --output=circos.out
#SBATCH --error=circos.err
#SBATCH --mail-user=kcl58759@uga.edu
#SBATCH --mail-type=END,FAIL

ml Circos/0.69-6-GCCcore-8.3.0-Perl-5.30.0

circos -conf circos.conf
