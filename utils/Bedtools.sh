#!/bin/bash
#SBATCH --job-name=bedtools
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=90gb
#SBATCH --time=99:00:00
#SBATCH --output=bedtools.out
#SBATCH --error=bedtools.err
#SBATCH --mail-user=kcl58759@uga.edu
#SBATCH --mail-type=END,FAIL

ml BEDTools/2.30.0-GCC-10.2.0

bedtools genomecov -i 212_l0tobasereads.bam -g /scratch/kcl58759/Eco_pacbio_kendall/Hifiasm_stuff/212_assemblies/212.l0/212_l0.fa.fai


212_l0tobasereads.bam
#If you want to plot the coverage over the genome, you’ll probably do that by calculating average coverage over genome windows. If you’ve already mapped some reads to the genome then BEDtools will be able to handle everything else.

#The first thing you’ll need are the windows themselves. I usually aim for ~1000 windows total; so for a 13 Mb genome I’ll use 25 kb windows with 12 kb steps.


bedtools makewindows -g genome.fasta.fai -w 25000 -s 12500 > genome.windows

#To calculate the window coverage, I find BEDtools multicov is an ok approximation (it counts the reads per window rather than read-depth).

bedtools multicov -bams aligned.bam -bed genome.windows > genome.cov.histogram
