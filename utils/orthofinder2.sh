#!/bin/bash
#SBATCH --job-name=orthofinder
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=60gb
#SBATCH --time=160:00:00
#SBATCH --output=orthofinder.%j.out
#SBATCH --error=orthofinder.%j.error

#example
# replace every instance of "unix" to "linux"
#sed 's/unix/linux/g' input > output

# replace every instance of "unix" to "linux"
#sed 's/>E.coenophial. />E.coenophiala.19_:/g' input.fasta > output.fasta

# load orthofinder2
cd $SLURM_SUBMIT_DIR
ml OrthoFinder/2.3.11-intel-2019b-Python-3.7.4
ml MAFFT/7.470-GCC-8.3.0-with-extensions
ml IQ-TREE/1.6.12-foss-2019b
# run orthofinder using mafft multiple sequence aligner and iqtree for ML gene tree estimation
#orthofinder -d -t 64 -M msa -A mafft -T iqtree -f <dir>

#add and remove species from a previous run
#previous_OF_directory = SpeciesIDs.txt from previous OF Return
#comment out any species you want to be removed from SpeciesIDs.txt
orthofinder -b /scratch/kcl58759/Eco_pacbio_kendall/Orthofinder/sequences/OrthoFinder/Results_Feb08_3/WorkingDirectory -f new_fasta_directory -M msa -A mafft -T iqtree



# CITATIONS:
# When publishing work that uses OrthoFinder please cite:
# Emms D.M. & Kelly S. (2019), Genome Biology 20:238

# If you use the species tree in your work then please also cite:
# Emms D.M. & Kelly S. (2017), MBE 34(12): 3267-3278
# Emms D.M. & Kelly S. (2018), bioRxiv https://doi.org/10.1101/267914
