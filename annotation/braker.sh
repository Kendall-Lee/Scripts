#!/bin/sh
#SBATCH -e braker_hap2_%j.err
#SBATCH -o braker_hap2_%j.out
#SBATCH --job-name=braker_hap2
#SBATCH --time-min=120:00:00
#SBATCH -c 48
#SBATCH --mem=300G
#SBATCH --partition=highmem
#SBATCH --nodes=1

module load cluster/singularity/3.11.0

singularity exec --bind /cluster /cluster/lab/clevenger/KLee/braker3_latest.sif braker.pl --genome=/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Suziblue_renamed_reordered.fa.mod.MAKER.masked --prot_seq=/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/BRAKER_proteins.fasta --threads=48 --rnaseq_sets_ids=SRR1187676,SRR1187677,SRR30252211,SRR30252214,SRR30252215,SRR30252216,SRR30252217,SRR30252218,SRR33474177,SRR33474179,SRR5036131 --rnaseq_sets_dirs=/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/RNA_seq_data/clean_RNA
