#!/bin/bash
#SBATCH --job-name=mafft
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --mem=50gb
#SBATCH --time=10:00:00
#SBATCH --ntasks-per-node=8
#SBATCH --output=mafft.%j.out
#SBATCH --error=mafft.%j.error

## load mafft
ml MAFFT/7.487-gompi-2019b-with-extensions
## make multiple sequence alignment using mafft's accuracy-oriented method (*L-INS-i)
  # this outputs a fasta file
mafft --thread 8 --nuc --localpair --maxiterate 1000 perA_seqs.fasta > perA.aln
mafft --thread 8 --nuc --localpair --maxiterate 1000 TefA_seqs.fasta > tefA.aln
mafft --thread 8 --nuc --localpair --maxiterate 1000 tubB_seqs.fasta > tubB.aln
