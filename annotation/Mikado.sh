#!/bin/bash
#SBATCH --job-name=mikado
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=55G
#SBATCH --time=04:00:00
#SBATCH --output=agat_gffread.%j.out
#SBATCH --error=agat_gffread.%j.err
############################################################
## activate agat env
eval "$(conda shell.bash hook)"
conda init
conda activate mikado_env



mikado configure \
    --reference /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_Full.fa \
    --mode permissive \
    --annotation /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Gene_prediction/Suziblue_full_tiberius.gff3 \
    --annotation /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Gene_prediction/Suziblue_helixer.checked.gff3 \
    mikado_config.yaml
