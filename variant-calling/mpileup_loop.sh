#!/bin/bash
#SBATCH -J makepileup_array
#SBATCH --time=24:00:00               # shorter runtime per job, adjust as needed
#SBATCH -c 1                         # 1 CPU per task (mpileup is mostly single-threaded)
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem=16G                   # reduce memory since single job
#SBATCH -o "stds2/stdout_%x_%A_%a"  # %A = job ID, %a = array index
#SBATCH -e "stds2/stderr_%x_%A_%a"
#SBATCH --array=1-147              # Replace 100 with number of BAM files


#before submititing do ls "$BAMDIR"/*.bam > bam_list.txt
#submit like sbatch --array=1-$(wc -l < bam_list.txt) mpileup.sh


module load samtools/1.19.2-gcc-13.1.0

REF="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.fasta"
BAMDIR="/cluster/lab/clevenger/KLee/Dosage_testing/W85_ref/RE_bwa"
OUT_DIR="/cluster/lab/clevenger/KLee/Dosage_testing/W85_ref/MPILEUP_files"
VCFDIR="/cluster/lab/clevenger/KLee/Dosage_testing/W85_ref/VCF_files"

BAM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" bam_list.txt)
base=$(basename "$BAM" .bam)
vcf="$VCFDIR/${base}.vcf"
bed="$OUT_DIR/${base}.snp.bed"

echo "Processing sample: $base"

if [[ ! -f "$vcf" ]]; then
    echo "VCF file not found for $base at $vcf, skipping..."
    exit 0
fi

# Make BED
awk -F'\t' 'BEGIN {OFS="\t"} !/^#/ {print $1, $2-1, $2}' "$vcf" > "$bed"

# Run mpileup
samtools mpileup -f "$REF" -l "$bed" "$BAM" > "$OUT_DIR/${base}.bam_minipileup.pileup"

echo "Done $base"
