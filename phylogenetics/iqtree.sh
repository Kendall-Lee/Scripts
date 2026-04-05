#!/bin/bash
#SBATCH --job-name=iqtree
#SBATCH --partition=batch
#SBATCH --mem=20gb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=10:00:00
#SBATCH --output=iqtree.%j.out
#SBATCH --error=iqtree.%j.error

## load iqtree
ml IQ-TREE/2.2.2.6-gompi-2022a
## make gene tree using 100 standard non parametrix bootstraps
#iqtree2 -s TefAgens.aln -bb 1000 -T 12 -pre rapidboot.test
# use -wbt option (which writes bootstrap trees to a separate file) when make gene trees for input into ASTRAL-PRO
## example:
iqtree2 -s tubB_genes.aln -b 100 -wbt -nt 4 -pre tubB_genes
