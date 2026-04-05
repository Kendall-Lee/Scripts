#!/bin/bash
#SBATCH -J @code_PGH_lK_LR
#SBATCH --time=96:00:00
#SBATCH -c 1
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem="128G"

# | sed "s:@proj::g; s:@code::g; s:lK_LR::g; s:@PARHap::g; s:Wiregrass_LRLP_linear_03.hapmap::g" > 09_khufu_lK_LR.sh

# set paths and variables
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source "$khufu_dir"/utilities/load_modules.sh

PARHap="/cluster/lab/clevenger/KLee/HifiPlex_May_2024/parent_guided_work/parents.hapmap"
progHap="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/Linear_hapmaps/Wiregrass_LRLP_linear_03.hapmap"

# get alleles of parent hapmap
hapmapGetAlleles $PARHap > out1_lK_LR.txt

# hide all alleles that are not homozygous polymorphic
cat out1_lK_LR.txt | awk '{if (($1 ~ /,/) && (length($1) == 3) || $1 == "alleles") print $0; else print "-"}' > out2_lK_LR.txt

# filter parent hapmap for homozygous polymorphic sites only
paste <(cat out2_lK_LR.txt) <(cat $PARHap) | awk '{if ($1 != "-") print $0}' | cut -f2- > out3_lK_LR.txt

# merge parent and progeny hapmaps
merge2hapmaps out3_lK_LR.txt $progHap > out4_lK_LR.txt
echo out4_lK_LR.txt > hapmaps.list

# run 09_khufu
"$khufu_dir"/khufuChip/09_GenoC_chip.sh \
-bams /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/Linear_bams \
-l hapmaps.list \
-o lK_LR.hapmap \
-maf 0.1 \
-miss 0.75 \
-t 36 \
-Smiss 1 \
-FilterHet "FALSE" \
-het 0.90 \
-win 10 \
-LowFreqMask 0.01

hapmap2panmap lK_LR.hapmap "Bailey2,florida07,IAC322,ICG1471,TifNV" > lK_LR.panmap

##
t=12
EVAL=1
err=4
MBG=1e6
groups=10
correct=1
graph=0
gaps=1
output="lK_LR.Ipanmap"
##
"$khufu_dir"/spartan/spartanVI.sh -panmap "$panmap" \
-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output" --clean

EVAL=0

"$khufu_dir"/spartan/spartanVI.sh -panmap "$panmap" \
-t "$t" -EVAL "$EVAL" -err "$err" -MBG "$MBG" -groups "$groups" -correct "$correct" -graph "$graph" -gaps "$gaps" -o "$output" --clean

# Hawk
panmap="lK_LR.Ipanmap"
bed="QTLsKL.bed"
background="TifNV"
MinNumPerRegion=10
missCutoff=0.3
dominance=0.5
###
"$khufu_dir"/khufuHawkII/hawk.sh -panmap "$panmap" -bed "$bed" -background "$background" \
   -MinNumPerRegion "$MinNumPerRegion" -missCutoff "$missCutoff" -dominance "$dominance" --clean

# clean up tmp files
#rm out1_lK_LR.txt
#rm out2_lK_LR.txt
#rm out3_lK_LR.txt
#rm out4_lK_LR.txt
