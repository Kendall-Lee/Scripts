#!/bin/bash
#SBATCH --job-name=ref
#SBATCH --partition=khufu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=350gb
#SBATCH --time=04:00:00
#SBATCH --output=stds/bedtools.@id.%j.out
#SBATCH --error=stds/bedtools.@id.%j.error

##################
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
"$khufu_dir"/utilities/ref.sh -ref /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Hifiasm_OmniC/Suziblue_renamed_reordered.fa
