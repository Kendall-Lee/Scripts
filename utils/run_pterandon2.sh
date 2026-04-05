#!/bin/bash

#SBATCH -J pteranodon
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"
##################
#prior to running:
#1.index ref and query files using bwa index & make sure permissions are correct
#2.add R packages stringr & data.table, to install R packages do ssh compile-c7-02 and install from there
#shiny app = https://w-korani.shinyapps.io/pterandon_wings/
##################
pteranodon="/cluster/home/wkorani/korani_aps/pteranodon"
t="24" #most efficient to do # of chromosomes
ref="/cluster/home/klee/PacBio_project/ref.fa"
query="/scratch/lab/clevenger/Pteranodon/GA12Y_hifiasm_TRhic_revision.fasta"  #make sure files are unzipped and indexed with BWA
#out="/scratch/lab/clevenger/Pteranodon/Florida07_1k_out"
len=1000 #length of kmers, thousand as default
min=3 #minimum length of the scaffold in mb
#################
#"$pteranodon"/get_plot_based_on_local_alignment.sh $pteranodon $t $ref $query $out $len $min
################
#round2
fa="/scratch/lab/clevenger/Pteranodon/Georganic_hifiasm_IChic_revision.fasta"
./round1.sh $pteranodon $(echo $query | sed "s:[.].*::g" |  sed "s:^:"$out"/:g") $fa
out=""$out"_round2"
"$pteranodon"/get_plot_based_on_local_alignment.sh $pteranodon $t $ref $fa $out $len $min
