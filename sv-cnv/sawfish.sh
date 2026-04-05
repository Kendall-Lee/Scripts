#!/bin/bash
#SBATCH -J sawfish
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p plant
#SBATCH -o "stds/stdout_sawfish"
#SBATCH -e "stds/stderr_sawfish"
#SBATCH --mem="200G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL

#map samples using pbmm2 first########

# eval "$(conda shell.bash hook)"
# conda init
# conda activate sawfish

### March 2025, Kendall Lee #######

#Reference assembly in fasta format
# ref="chr18.fasta"
# #query to ref bam file
# bam="noHclip.bam"
/cluster/home/klee/sawfish-v2.0.0-x86_64-unknown-linux-gnu/bin/sawfish discover \
  --threads 16 \
  --ref chr18.fasta \
  --bam noHclip.bam \
  --cov-regex "."


/cluster/home/klee/sawfish-v2.0.0-x86_64-unknown-linux-gnu/bin/sawfish   joint-call --threads 16 --sample sawfish_discover_output --output-dir Remi_joint_call_dir
