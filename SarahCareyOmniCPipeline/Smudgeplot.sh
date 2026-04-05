#!/bin/bash
#SBATCH -e Smudgeplot_%j.err
#SBATCH -o Smudgeplot_%j.out
#SBATCH --job-name=Smudgeplot
#SBATCH --time-min=120:00:00
#SBATCH --ntasks=80
#SBATCH --mem=640G
#SBATCH --partition=plant
#SBATCH --nodes=1
#
# eval "$(conda shell.bash hook)"
# conda init
# conda activate base
#
#
#
# # sort them in a reasonable place
# mkdir data/Scer
# mv *fastq.gz data/Scer/
#
# # run FastK to create a k-mer database
# FastK -v -t4 -k31 -M16 -T4 /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Raw_data/B791_merge1.fastq

eval "$(conda shell.bash hook)"
conda init
conda activate smudgeplot_env

# Find all k-mer pairs in the dataset using hetmer module
smudgeplot.py hetmers -L 12 -t 4 -o FastK/kmerpairs --verbose FastK
# this now generated `data/Scer/kmerpairs_text.smu` file;
# it's a flat file with three columns; covB, covA and freq (the number of k-mer pairs with these respective coverages)

# use the .smu file to infer ploidy and create smudgeplot
smudgeplot.py all -o data/Scer/trial_run data/Scer/kmerpairs_text.smu

# check that bunch files are generated (3 pdfs; some summary tables and logs)
ls data/Scer/trial_run_*
