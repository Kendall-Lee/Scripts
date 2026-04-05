#!/bin/bash
#SBATCH --job-name=Anvio
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=50gb
#SBATCH --time=10:00:00
#SBATCH --output=anvio.out
#SBATCH --error=Anvio.err
#SBATCH --mail-user=kcl58759@uga.edu
#SBATCH --mail-type=END,FAIL


ml anvio/7.1_conda

anvi-gen-contigs-database -f /scratch/kcl58759/Eco_pacbio_kendall/Hifiasm_stuff/1033_assemblies/1033_l0/1033.l0.fa -p 1033
anvi-profile -i /scratch/kcl58759/Eco_pacbio_kendall/Mapping_attempts/1033_l0_basereads.sam -c CONTIGS.db
