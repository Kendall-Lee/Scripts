#!/bin/bash
#SBATCH --job-name=meryl_B080
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=500gb
#SBATCH --time=100:00:00
#SBATCH --output=stdout/meryl.%j.out
#SBATCH --error=stdout/meryl.%j.error
###################################
###################################
eval "$(conda shell.bash hook)"
conda init
conda activate merqury
###################################
###################################

# set number of threads
OMP_NUM_THREADS=12
# path to hap1 fasta
f1='/cluster/lab/clevenger/VPerez/Horse_Assembly/'
# path to reads
reads='/cluster/lab/clevenger/VPerez/Horse_Assembly/m84238_250614_102330_s3.hifi_reads.fastq'
# prefix for output
pre="Horse"
###################################
###################################
ml purge
# load Merqury
ml cluster/meryl/1.4.1
###################################
###################################
###################################
# run Meryl to make kmer counts file
meryl count k=21 output ${pre}.meryl $reads threads=12
# generate histogram
meryl histogram ${pre}.meryl > ${pre}.meryl.hist
# run Merqury
$MERQURY/merqury.sh ${pre}.meryl $f1 $f2 ${pre}.merqury.out
