#!/bin/sh
#SBATCH -e fastk_%j.err
#SBATCH -o fastk_%j.out
#SBATCH --job-name=fastk
#SBATCH --time-min=120:00:00
#SBATCH -c 50
#SBATCH --mem=100G
#SBATCH --partition=highmem
#SBATCH --nodes=1

FastK -v -t10 -k21 -M100 -T50 B278_final.fastq -Nkmer_db

Histex -G kmer_db > B278_kmer_k21.hist

#!/bin/sh
#SBATCH -e smudgeplot_%j.err
#SBATCH -o smudgeplot_%j.out
#SBATCH --job-name=smudgeplot
#SBATCH --time-min=120:00:00
#SBATCH -c 50
#SBATCH --mem=100G
#SBATCH --partition=highmem
#SBATCH --nodes=1


L=30
smudgeplot.py cutoff B278_kmer_k21.hist -o B278_cutoff.png

smudgeplot.py hetmers -L "$L" -t 4 -o kmerpairs_L"$L" kmer_db

smudgeplot.py all -cov_min 40 -cov_max 1000 -o B278_1000 -t "B278" kmerpairs_L30_text.smu
