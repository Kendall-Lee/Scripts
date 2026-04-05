#!/bin/bash
#SBATCH -J 114_Sp6
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="256G"
###############
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
##############
panmap="SHB_Smiss0.8_miss0.8_maf0.1.panmap"
##
t=24
EVAL=1
err=3
MBG=1e11
groups=12
correct=1
graph=0
gaps=1
##
#"$khufu_dir"/spartan/spartanVI.sh -hapmap "$hapmap" -hapParentIDs "$hapParentIDs" \
#-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output" --clean
#"$khufu_dir"/spartan/spartanVI.sh -hapmap "$hapmap" -hapNumOfParents "$hapNumOfParents" \
#-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output" --clean
"$khufu_dir"/spartan/spartanVI.sh -panmap "$panmap" \
-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output.test" --clean

EVAL=0
"$khufu_dir"/spartan/spartanVI.sh -panmap "$panmap" \
-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output.test" --clean
