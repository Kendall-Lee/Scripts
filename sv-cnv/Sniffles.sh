#!/bin/bash
#SBATCH --job-name=sniffles_call
#SBATCH --array=1-95
#SBATCH -e logs/snf_%A_%a.err
#SBATCH -o logs/snf_%A_%a.out
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --partition=normal

set -euo pipefail

ml cluster/sniffles/2.2

mkdir -p sv_calls logs

REF=/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" bamlist.txt)
SAMPLE_NAME=$(basename $SAMPLE .bam)

echo "Calling SVs for: $SAMPLE_NAME"

sniffles \
   --input $SAMPLE \
   --vcf sv_calls/${SAMPLE_NAME}.vcf.gz \
   --snf sv_calls/${SAMPLE_NAME}.snf \
   --threads 4 \
   --minsvlen 25 \
   --mapq 20 \
   --minsupport 2 \
   --reference $REF

echo "Completed: $SAMPLE_NAME"


#!/bin/bash
#SBATCH --job-name=sniffles_merge
#SBATCH -e sniffles_merge_%J.err
#SBATCH -o sniffles_merge_%J.out
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=32G
#SBATCH --partition=normal

set -euo pipefail

ml cluster/sniffles/2.2

# Create list of SNF files
ls sv_calls/*.snf > snf_list.txt

echo "Merging $(wc -l snf_list.txt) samples..."

sniffles \
   --input snf_list.txt \
   --vcf LRLP_suzihap1_SVs_raw.vcf.gz \
   --threads 10 \
   --minsvlen 50

bcftools index LRLP_suzihap1_SVs_raw.vcf.gz

echo "Filtering SVs..."
bcftools filter \
   -i 'QUAL>=20 && INFO/SUPPORT>=5' \
   LRLP_suzihap1_SVs_raw.vcf.gz \
   -Oz -o LRLP_suzihap1_SVs_filtered.vcf.gz

bcftools index LRLP_suzihap1_SVs_filtered.vcf.gz

echo "SV calling complete!"
