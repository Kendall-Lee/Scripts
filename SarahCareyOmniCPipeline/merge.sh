#!/bin/bash
#SBATCH -J merge_loop
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_pankmer"
#SBATCH -e "stds/stderr_pankmer"
#SBATCH --mem="200G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL
#to merge all txt files in loop

#to merge all the indel.hapmaps together 
#load khufu env
srun -c 4 --mem=40G -p interactive --pty /bin/bash
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source "$khufu_dir"/utilities/KhufuEnvVer2.sh
#run merge loop
#for i in $(ls *.indels.txt); do merge merge.txt $i > test.txt ; mv test.txt merge.txt ; done
for i in $(ls *indels.hapmap); do merge2hapmaps merge.hapmap $i > test.hapmap; mv test.hapmap merge.hapmap; done
#to sort the chromosome positions
cat merge.txt | cut -f1 | tr '_' '\t' | sort -k1,1 -k2,2n | tr '\t' '_'

## to check sameness for vcf5 and vcf9
LRLPPan.vcf9 | cut -f1,3 | tr ',' '\t' | cut -f1,2 | paste - C431_HIFI.vcf5 | awk '{if ($2 > 0) print $0}' | tr ';' '\t' | awk '{if ($4 > 1) print $0}' | cut -f2,3 | sort | uniq -c
