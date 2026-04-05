#!/bin/bash
#SBATCH --job-name=iqtree
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --mem=20gb
#SBATCH --time=10:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --output=iqtree.%j.out
#SBATCH --error=iqtree.%j.error

# Set the output file name
output_file="concatenated.fasta"

# Remove the output file if it already exists
rm -f $output_file

# Loop through all fasta files in the current directory
for file in *.faa
do
  # Append the contents of each file to the output file
  cat $file >> $output_file
done
## load iqtree
ml IQ-TREE/2.2.0-GCC-10.2.0-nompi
## make gene tree using 100 standard non parametrix bootstraps
iqtree2 -redo -s supermatrix.nexus -spp characterset.nexus -bb 1000 -T 12 -pre rapidboot.test

# use -wbt option (which writes bootstrap trees to a separate file) when make gene trees for input into ASTRAL-PRO
## example:
# iqtree -s matrix.nexus -b 100 -wbt -nt 4 -pre prefix
