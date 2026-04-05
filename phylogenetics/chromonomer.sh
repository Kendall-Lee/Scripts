#!/bin/bash
#SBATCH -J chromonomer
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p normal
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="200G"

#https://catchenlab.life.illinois.edu/chromonomer/manual/#exec
#kendall lee, June 2025

fasta="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Assembly/Haps/B791_Uncurated_Haps.JBAT.review.assembly.fa.FINAL.fa.gz"
map="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Linkage_mapping/marker_descriptor.tsv"
agp="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Linkage_mapping/test.agp"
aln="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Linkage_mapping/LGmarkedB791yahs.sorted.bam"
out="B791Yahs_chromonomer"


/cluster/home/klee/chromonomer-1.15/chromonomer --map $map --alns $aln --agp $agp --out_path $out --fasta $fasta

#build the agp file from a fasta file

#/cluster/home/klee/chromonomer-1.15/scripts/fasta2agp.py --fasta /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Assembly/Haps/B791_Uncurated_Haps.JBAT.review.assembly.fa.FINAL.fa.gz --agp /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Linkage_mapping


NC_091686.1_RagTag:39108337-39110056
