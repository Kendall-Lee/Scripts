#!/bin/bash
#SBATCH --job-name=freebayes
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=logs/freebayes_SHB_%j.out
#SBATCH --error=logs/freebayes_SHB_%j.err
#SBATCH --partition=plant
#SBATCH --array=1-534

# Load FreeBayes module
module load cluster/freebayes/1.3.1

# ls Combined_SR_BAMS/*.bam \
#   | sed 's#.*/##' \
#   | sed -E 's/(\.combined)?\.bam$//' \
#   > sample_list.txt


# # Get sample ID
# line=$(sed -n "${SLURM_ARRAY_TASK_ID}p"  sample_list.txt)
# id="$line"

# Define paths
REF=/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa
BAM=./Combined_SR_BAMS/${id}.combined.bam
OUTVCF=./Combined_VCF/${id}.combo.vcf

# Run FreeBayes jointly across all BAMs
freebayes -f $REF -b $BAM \
  --use-best-n-alleles 4 \
  --min-coverage 10 \
  --genotype-qualities \
  --report-genotype-likelihood-max \
  --dont-left-align \
  -v $OUTVCF



########### sample list only ######################
#!/bin/bash
#SBATCH --job-name=freebayes_trinity
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem=64G
#SBATCH --partition=plant
#SBATCH --array=1-$(wc -l < /cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/trinity_sample_list.txt)
#SBATCH -o freebayes_trinity_%A_%a.out
#SBATCH -e freebayes_trinity_%A_%a.err
module load cluster/freebayes/1.3.1
# ---- USER PATHS ----
SAMPLE_LIST=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/trinity_sample_list.txt
REF=/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa
BAM_DIR=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_SR_BAMS
OUTDIR=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_VCF

mkdir -p "$OUTDIR"

# ---- Find which sample this array task should process ----
id=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

echo "Starting FreeBayes on sample $id (array task $SLURM_ARRAY_TASK_ID)"

BAM=${BAM_DIR}/${id}.combined.bam
OUTVCF=${OUTDIR}/${id}.combo.vcf

if [ ! -f "$BAM" ]; then
    echo "ERROR: Missing BAM for sample $id ($BAM)"
    exit 1
fi

# ---- Run FreeBayes on this sample ----
freebayes -f "$REF" -b "$BAM" \
  --use-best-n-alleles 4 \
  --min-coverage 10 \
  --genotype-qualities \
  --report-genotype-likelihood-max \
  --dont-left-align \
  -v "$OUTVCF"

echo "Sample $id finished."
