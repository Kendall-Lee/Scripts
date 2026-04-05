#!/bin/bash
#SBATCH -e smudge_compute_%j.err
#SBATCH -o smudge_compute_%j.out
#SBATCH --job-name=smudge_compute
#SBATCH --time=48:00:00
#SBATCH -c 32
#SBATCH --mem=500G
#SBATCH --partition=highmem
#SBATCH --nodes=1

eval "$(conda shell.bash hook)"
conda init
conda activate base

ml cluster/meryl/1.4.1

# Set input variables
MERYL_DB="B080.meryl"  # the directory output from meryl count
KMER_HIST="B080.meryl.hist"
KMER_DUMP="B080_REmeryl_kmers.txt"
FILTERED_KMERS="B080_meryl_filtered.txt"

# Step 1: Estimate L and U cutoffs from meryl.hist
L=$(smudgeplot.py cutoff $KMER_HIST L)
U=$(smudgeplot.py cutoff $KMER_HIST U)
echo "Estimated L: $L"
echo "Estimated U: $U"

# Step 2: Dump k-mers from meryl
meryl print $MERYL_DB > $KMER_DUMP

# Step 3: Filter based on L and U
awk -v l=$L -v u=$U '$2 >= l && $2 <= u' $KMER_DUMP > $FILTERED_KMERS

# Step 4: Run hetmers (k-mer pair generation) — replaces need for kmc/smudge_pairs
smudgeplot.py hetmers -o smudge_B080 $FILTERED_KMERS


#!/bin/bash
#SBATCH -e smudge_plot_%j.err
#SBATCH -o smudge_plot_%j.out
#SBATCH --job-name=smudge_plot
#SBATCH --time=12:00:00
#SBATCH -c 16
#SBATCH --mem=250G
#SBATCH --partition=highmem
#SBATCH --nodes=1

# Make sure the output from the first job exists
COVERAGE_TSV="smudge_B080_coverages.tsv"

# Step 1: Run smudgeplot
smudgeplot.py plot -o Comptonia -t "Comptonia" $COVERAGE_TSV
