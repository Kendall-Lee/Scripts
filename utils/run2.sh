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
./round2.sh $pteranodon /cluster/home/klee/CB7_project/CB7_1k_out/CB7_hifiasm CB7_IAC322_pteran.out
