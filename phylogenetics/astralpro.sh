#!/bin/bash
#SBATCH --job-name=ASTRALpro
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=30gb
#SBATCH --time=40:00:00
#SBATCH --output=astralpro.%j.out
#SBATCH --error=astralpro.%j.error


## Concatenate bipartition trees into one file
cat *.treefile > biparts.tre

## load astral-pro
ml ASTRAL-Pro/1.10.1.3-fosscuda-2020b
## estimate species tree and account for paralogs
astral-pro -t 8 -i biparts.tre -o astralpro_output.tre 2>astralpro.log

## load ASTRAL-III
ml ASTRAL/5.6.1-Java-1.8.0_144
## annotate branches with alt posterior probs
time java -jar $EBROOTASTRAL/astral.5.6.1.jar -q astralpro_output.tre -i biparts.tre -t 4 -o astralpro.scored-t4.tre
## annotate branches with alt quartet freqs
time java -jar $EBROOTASTRAL/astral.5.6.1.jar -q astralpro_output.tre -i biparts.tre -t 8 -o astralpro.scored-t8.tre
