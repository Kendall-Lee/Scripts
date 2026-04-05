#!/bin/bash
#SBATCH --job-name=bcftools_call
#SBATCH -e bcftools_call_%J.err
#SBATCH -o bcftools_call_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=100G
#SBATCH --partition=normal




ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0
ml samtools/1.19.2-gcc-13.1.0

for bam in *.sorted.bam
do
    samtools index $bam
done


bcftools mpileup \
   -f /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa \
   -b bamlist.txt \
   -q 20 \
   -Q 20 \
   -Ou \
   --threads 24 \
| bcftools call \
   -mv \
   -Oz \
   --threads 24 \
   -o LRLP_suzihap1_raw.vcf.gz

   bcftools index LRLP_suzihap1_raw.vcf.gz


   bcftools filter \
   -e 'QUAL<20 || DP<2' \
   LRLP_suzihap1_raw.vcf.gz \
   -Oz \
   -o LRLP_suzihap1_filtered.vcf.gz
