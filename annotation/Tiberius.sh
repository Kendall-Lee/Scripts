#!/bin/bash
#SBATCH -J Tiberius
#SBATCH --time=96:00:00
#SBATCH -c 16
#SBATCH -N 1
#SBATCH -p highmem
#SBATCH -o "stds/stdout_tiberius"
#SBATCH -e "stds/stderr_tiberius"
#SBATCH --mem="400G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL

#will default to myenv python so need to do conda deactivate 2x to make sure that once is shut down before activating Tiberius

eval "$(conda shell.bash hook)"
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/tiberius

ml cluster/singularity/3.11.0
#you need to move the genome you are using to /cluster/home/klee or else it won't be able to find it
#I dont know a better workaround yet
python /cluster/home/klee/Tiberius/tiberius.py --singularity --genome /cluster/home/klee/Suziblue_renamed_reordered.fa.mod.MAKER.masked --out /cluster/home/klee/Suziblue.gtf --model_cfg /cluster/home/klee/Tiberius/model_cfg/eudicotyledons.yaml
