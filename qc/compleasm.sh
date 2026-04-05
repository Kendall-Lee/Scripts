#!/bin/bash
#SBATCH -e compleasm_%j.err
#SBATCH -o compleasm_%j.out
#SBATCH --job-name=compleasm
#SBATCH --time-min=120:00:00
#SBATCH --ntasks=80
#SBATCH --mem=640G
#SBATCH --partition=khufu
#SBATCH --nodes=1

# Set variables
genome="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Primary_hifiasm/B080_RE.hifiasm.hic.p_utg.fa"
output_dir="./B080_utg_unfiltered"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"
# #/cluster/home/klee/compleasm_kit/compleasm.py download eudicots_odb10
# # with lineage specified
# /cluster/home/klee/compleasm_kit/compleasm.py run \
#   -a genome.fasta \
#   -o output_dir \
#   -l eudicots_odb10 \
#   --odb odb10 \
#   -L /cluster/home/klee/busco_lineages \
#   -t 8
# # autolineage mode
# python compleasm.py run -a $genome -o $output_dir -t 8 --autolineage

compleasm run -a /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Primary_hifiasm/B080_RE.hifiasm.hic.p_utg.fa -o B080_utg_unfiltered -l eudicots_odb10  --odb odb10 -L /cluster/home/klee/busco_lineages
