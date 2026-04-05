#!/bin/bash
#SBATCH -J @code_Sp6
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="50G"
###############
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
##############
hapmap="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/Wiregrass_LRLP_linear_09.hapmap "
output="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/Wiregrass_LRLP_linear_09.Ihapmap "
hapNumOfParents=16
##
t=12
EVAL=1
err=4
MBG=1e6
groups=10
correct=1
graph=0
gaps=1
##
"$khufu_dir"/spartan/spartanVI.sh -hapmap "$hapmap" -hapParentIDs "$hapParentIDs" \
-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output" --clean
