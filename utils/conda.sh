#!/bin/bash
#SBATCH -J conda
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_conda
#SBATCH -e stderr_conda
#SBATCH --mem="200G"



mamba env create -f Arima_Hive_pore_c_py_env.yml -n custom_cutter_CiFi_env
