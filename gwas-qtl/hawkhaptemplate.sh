#!/bin/bash
#SBATCH -J Hawk
#SBATCH --time=96:00:00
#SBATCH -c 4
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="64G"
###############
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
t=$SLURM_JOB_CPUS_PER_NODE
panmap="MagicRedoPanDownsampleParent_Smiss0.9_miss0.9_maf0.0.panmap"
bed="/cluster/projects/khufu/korani_projects/LRLPII/qtlNew.bed"
background="All"
MinDep=1
dominance=1
graph=0
output=""$panmap"_dom"$dominance"_MinDep"$MinDep".hawk"
###
/cluster/projects/khufu/qtl_seq_II/khufu_II/hawk/hawkIV.sh -panmap "$panmap" -bed "$bed" -background "$background" \
   -MinDep "MinDep" -dominance "$dominance" -o "$output" -graph "$graph"
