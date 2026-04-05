#!/bin/bash
#SBATCH --job-name=TE_annotation
#SBATCH -e edta_%J.err
#SBATCH -o edta_%J.out
#SBATCH --time=480:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=30
#SBATCH --mem=256G
#SBATCH --partition=khufu

#
# GENOMETools=/cluster/home/klee/genometools/bin perl /cluster/home/klee/EDTA/EDTA.pl \
#   --genome Suziblue_renamed_reordered.fa \
#   --overwrite 1 \
#   --anno 1 \
#   --sensitive 1 \
#   --threads 25
#


module load cluster/edta/2.2.2

cd $JOB_TMP_DIR

EDTA.pl --genome /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Hifiasm_OmniC/Suziblue_renamed_reordered.fa --overwrite 1 --sensitive 1 --anno 1 --evaluate 0 --threads 25

cp -R $JOB_TMP_DIR/ /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Hifiasm_OmniC/Suziblue_final/repeats
