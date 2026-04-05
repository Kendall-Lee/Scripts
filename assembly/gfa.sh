#!/bin/bash
#SBATCH -J PanRef
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="384G"
###############
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
gfa="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Pangenome/BlubPutgPan_REFproc/BlubPutgPan.sv.gfa.gz"
t=12
###
"$khufu_dir"/khufuPAN/gfa.sh -gfa "$gfa" -t "$t"
