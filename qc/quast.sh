#!/bin/bash
#SBATCH -J quast
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_quast
#SBATCH -e stderr_quast
#SBATCH --mem="300G"

/cluster/home/klee/Software/quast-5.2.0/quast.py B791_Hap1_filtered.fasta -o B791_Hap1_filtered

/cluster/home/klee/Software/quast-5.2.0/quast.py /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Primary_hifiasm/B080_RE.hifiasm.hic.hap2.p_ctg.fa -o B080_RE.hifiasm.hic.hap2.p_ctg
