#!/bin/bash
#SBATCH -J ref
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="64G"


#t="24"
#ref="/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa"
#query="/cluster/lab/clevenger/hwright/peanut/peanut_PROC/Ascasubi.fa"
#o="newAsc"
#SegLen=1000
#MinQueryLen=10
#ScafPer=20

/cluster/projects/khufu/korani_projects/Pteranodon/scripts/PteranodonBase.sh -ref /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.fasta -query /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Redo_hifiasm/B791_uncurated_haps.fa -o 3B791_uncurated_hapsl0 -SegLen 1000 -MinQueryLen 3 -ScafPer 0.2 -t 24

#   -/-o  the output folder and prefix
#   -/--SegLen  query sequences are split into  segments of this size in bases
#   -/--MinQueryLen  query sequences less than this this megabases are excluded
#   -/--ScafPer  query seqeunces less than this percentage out of ref matches are excluded


#########################################################################
##change file names
for file in chr*_fixed*.fa; do
  new_name=$(echo "$file" | sed 's/chr\([0-9]*\)_fixed\([0-9]*\).fa/arahy.GA12Y.gnm1.chr\1.fa/')
  mv "$file" "$new_name"
done
#change headers in new fasta

#!/bin/bash

sed -i 's:>chr11_fixed11:>Florida07.Chr.11:g' Florida07Chr_hic_revision1_pteranodon.fa


https://w-korani.shinyapps.io/pterandon_wings/
