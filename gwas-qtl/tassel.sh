#!/bin/bash
#SBATCH -J Tassel
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="340G"

hapmap=" KHU100.8_SHB_min4_groups10.DiAllelic_noMissingData.IHapmap"
out="KHU100.8_SHB_min4_groups10.DiAllelic_noMissingData.PCA"
#/cluster/home/klee/tassel-5-standalone/run_pipeline.pl -Xmx64g -fork1 -h $hapmap -export -exportType VCF -runfork1

/cluster/home/klee/tassel-5-standalone/run_pipeline.pl -Xmx64g \
  -fork1 -h $hapmap \
  -pca \
  -export ${out}.pca.txt \
  -runfork1
