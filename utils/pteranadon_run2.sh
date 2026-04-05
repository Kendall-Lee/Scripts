#!/bin/bash
#SBATCH -J pteran
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"
###############
pteranodon="/cluster/home/wkorani/korani_aps/pteranodon"
t="12"
./round2.sh $pteranodon /cluster/lab/clevenger/KLee/BRUCE_hifiasm_hic/BRUCE_TR2_1k_out/Bruce.fa BRUCE_TR2_hic.out
