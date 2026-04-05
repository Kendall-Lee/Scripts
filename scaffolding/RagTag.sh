#!/bin/bash
#SBATCH --job-name=ragtag
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=480gb
#SBATCH -c 16
#SBATCH --time=400:00:00
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"

module load cluster/ragtag/2.1.0
module load cluster/minimap2/2.26

#id="@id"
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.chrOnly.fasta"
query="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B278/B278.asm.bp.p_utg.fa"
out="B278_utg_W85_scaff"

ragtag.py scaffold -o $out $ref $query


#### to generate script files ####
for i in $(ls cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Processed_Assemblies/*asm.bp.p_utg.filtered_contigs.fa| sed "s:.asm.bp.p_utg.filtered_contigs.fa::g; s:.*/::g"); do cat ./ragtag.sh| sed "s:@id:$i:g" > ragtag_"$i".sh; done


# First make an index of the fasta
samtools faidx B767_p_filt.ragtag.scaffold.fasta

# Extract just the 12 chromosomes into a new file
samtools faidx B767_p_filtragtag.scaffold.fasta \
  Chr.01_RagTag Chr.02_RagTag Chr.03_RagTag Chr.04_RagTag \
  Chr.05_RagTag Chr.06_RagTag Chr.07_RagTag Chr.08_RagTag \
  Chr.09_RagTag Chr.10_RagTag Chr.11_RagTag Chr.12_RagTag \
  > B767_p_filt.ragtag.chromosomes.fasta
Suziblue_hap1.fa
Suziblue_renamed_reordered.fa.gz
