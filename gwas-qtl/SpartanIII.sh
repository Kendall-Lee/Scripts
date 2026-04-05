#!/bin/bash
#SBATCH -J sparIII
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p highmem
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="600G"
################
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
t=$SLURM_JOB_CPUS_PER_NODE
### SpartanIII
hap="USDA_blub_miss_0.75_Smiss0.9.hapmap"
bams="./done/bams"
pos=5
het=0.6
K=8
nGen=100
###
"$khufu_dir"/spartan/run_spartan.sh -hap "$hap" -bams "$bams" -t "$t" -pos "$pos" -het "$het" -K "$K" -nGen "$mGen" -Eval TRUE -Imp TRUE

"$khufu_dir"/spartan/run_spartan.sh -hap "$hap" -bams "$bams" -t "$t" -pos "$pos" -het "$het" -K "$K" -nGen "$mGen" -Eval TRUE -Imp FALSE
