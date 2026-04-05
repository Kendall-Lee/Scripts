#!/bin/bash
#SBATCH -J QTLvarDTFruitDev_LR
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="192G"
###############
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
t=$SLURM_JOB_CPUS_PER_NODE
out="QTLvarFruitDev_redo_LR"
Hlist="FruitDev.more.high"
Llist="FruitDev.more.low"
bams="bams_LRLP"
n=5
bulkN=9
###
"$khufu_dir"/11_QTLvarIB.sh -t "$t" -o "$out" -Hlist "$Hlist" -Llist "$Llist" -bams "$bams" -n "$n" -bulkN "$bulkN"
