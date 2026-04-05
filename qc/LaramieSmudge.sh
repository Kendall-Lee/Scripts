#!/bin/bash
#SBATCH -e kmc_%j.err
#SBATCH -o kmc_%j.out
#SBATCH --job-name=kmc
#SBATCH --time-min=120:00:00
#SBATCH -c 32
#SBATCH --mem=500G
#SBATCH --partition=highmem
#SBATCH --nodes=1

eval "$(conda shell.bash hook)"
conda init
conda activate KMC

mkdir tmp
#ls *.fastq.gz > FILES
kmc -k21 -t16 -m64 -ci1 -cs10000 /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Raw_data/B791_merge1.fastq kmcdb tmp
kmc_tools transform kmcdb histogram kmcdb_k21.hist -cx10000


L=$(smudgeplot.py cutoff kmcdb_k21.hist L)
U=$(smudgeplot.py cutoff kmcdb_k21.hist U)
echo $L $U
# these need to be sane values
# L should be like 20 - 200
# U should be like 500 - 300
kmc_tools transform kmcdb -ci"$L" -cx"$U" reduce kmcdb_L"$L"_U"$U"
smudge_pairs kmcdb_L"$L"_U"$U" kmcdb_L"$L"_U"$U"_coverages.tsv kmcdb_L"$L"_U"$U"_pairs.tsv > kmcdb_L"$L"_U"$U"_familysizes.tsv

#!/bin/bash
#SBATCH -e smudgeplot_%j.err
#SBATCH -o smudgeplot_%j.out
#SBATCH --job-name=smudgeplot
#SBATCH --time-min=120:00:00
#SBATCH -c 32
#SBATCH --mem=500G
#SBATCH --partition=highmem
#SBATCH --nodes=1
eval "$(conda shell.bash hook)"
conda init
conda activate smudgeplot_env

smudgeplot.py plot -o B080 kmcdb_L"$L"_U"$U"_coverages.tsv
