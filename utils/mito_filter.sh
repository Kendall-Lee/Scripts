#!/bin/bash

# This script filters out likely mitochondrial scaffolds from
# genome a assembly. It looks for blast hits to a mitocondrial
# blast database with better than 75% nucleotide homology. If
# hits (collectively) cover more than 50% of the scaffold, it
# is deemed to be mitochondral.

#USAGE: ./mito_filter.sh <my_genome.fasta> <my_annotations.gff3>

# REQUIREMENTS:
# 1. You must have bedtools installed and in your path (v 2.24.0 or newer).
# 2. You must have blast installed and the excecutable
# "blastn" must be in your path.
# 3. You must have a blast database of mitochondrial genomes.
# you can use the one provided, which was made from fungal
# genome sequences downloaded from NCBI's organella database
# on the 4th of February 2014 (Mito_DB/MITO_DB).
# 4. You must specify the path and database name by opening
# this file in a text editor and editing the line below:

MITO_DB=/scratch/kcl58759/Eco_pacbio_kendall/212GeneAnnotation/Mito_DB/MITO_DB

# OUTPUTS:
# genome.fasta - your genome, with mitochondrial scaffolds removed
# mito.fasta - the scaffolds identified as mitochondrial
# annotation_noMito.gff3 - your annotation, with entries
# corresponding to mitochondrial scaffolds removed.

# WARNING:
# This script writes to files named "genome.fasta", "mito.fasta",
# "annotation_noMito.gff3" and uses temporary files "temp",
# "genome_list", "hits.bed", "scaffs.bed" and "mito_list".
# If you have files with these names in your working directory,
# they will be overwritten.

GFF=/scratch/kcl58759/Eco_pacbio_kendall/212GeneAnnotation/braker/braker.gtf
FASTA=/scratch/kcl58759/Eco_pacbio_kendall/Hifiasm_stuff/212_assemblies/212.l0/212_l0.fa

# Blast to all scaffold against the mitochondrial genome database
blastn -db $MITO_DB -query $FASTA -evalue 1e-10 -outfmt '6 qseqid sseqid pident qlen qstart qend' > temp

# Output hits with 75% or better homology to a bed file
awk '($3 > 75){print $1"\t"$5"\t"$6}' temp > hits.bed

# Make a bed file of the scaffolds
awk '($3 > 75){print $1"\t1\t"$4}' temp | sort | uniq > scaffs.bed

# Use bedtools to find the hit coverage on each scaffold
# Scaffolds with more 50% or more coverage by hits to mitochondrial DNA are
# deemed to be mitochondrial
bedtools coverage -a scaffs.bed -b hits.bed | awk '($7 >= .5){print $1}' > mito_list

rm hits.bed scaffs.bed

# Make a list of genomic scaffolds
cp $GFF annotation_noMito.gff3
grep ">" $FASTA | cut -f1 -d' ' | sed 's/>//g' | sort | uniq > temp
comm temp mito_list | cut -f1 | sort | uniq > genome_list
rm temp

#Make a file containing the mitochondrial scaffolds
while read line
do
 awk -v name=$line '{split($0,a," "); if(a[1] == ">"name){on="yes"};
                     if (substr($0,0,1) == ">" && a[1] != ">"name){on="no"};
                     if(on == "yes"){print}}' $FASTA
done < mito_list > mito.fasta

#Make a file containing the genomic scaffolds
while read line
do
 awk -v name=$line '{split($0,a," "); if(a[1] == ">"name){on="yes"};
                     if (substr($0,0,1) == ">" && a[1] != ">"name){on="no"};
                     if(on == "yes"){print}}' $FASTA
done < genome_list > genome.fasta

#Make a gff3 with entries corresponding to mitochondrial scaffolds removed
while read line
do
    grep -v $"${line}\t" annotation_noMito.gff3 > temp2
    mv temp2 annotation_noMito.gff3
done < mito_list
