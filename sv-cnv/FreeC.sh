#!/bin/bash
#SBATCH -J FREEC_array
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p plant
#SBATCH -o stds/stdout_%x_%A_%a
#SBATCH -e stds/stderr_%x_%A_%a
#SBATCH --mem=64G
#SBATCH --array=0-147 # REPLACE XX with number of BAM files

ml samtools/1.19.2-gcc-13.1.0
ml cluster/FREEC/11.6b
ml bedtools2/2.31.1-gcc-13.1.0

BAMDIR="/cluster/lab/clevenger/KLee/Dosage_testing/W85_ref/RE_bwa"
VCFDIR="/cluster/lab/clevenger/KLee/Dosage_testing/W85_ref/VCF_files"
PILEUPDIR="/cluster/lab/clevenger/KLee/Dosage_testing/W85_ref/MPILEUP_files"

# Get BAM file for this task ID
BAMFILE=$(ls ${BAMDIR}/*.bam | sed -n "${SLURM_ARRAY_TASK_ID}p")
if [[ -z "$BAMFILE" ]]; then
    echo "No BAM file found for task ID ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

BASENAME=$(basename "$BAMFILE" .bam)
VCFFILE="${VCFDIR}/${BASENAME}.vcf"
PILEUPFILE="${PILEUPDIR}/${BASENAME}.bam_minipileup.pileup"

if [[ ! -f "$VCFFILE" ]]; then
    echo "VCF file not found: $VCFFILE"
    exit 1
fi

if [[ ! -f "$PILEUPFILE" ]]; then
    echo "Pileup file not found: $PILEUPFILE"
    exit 1
fi

echo "Running FREEC on BAM: $BAMFILE"
echo "Using VCF: $VCFFILE"
echo "Using Pileup: $PILEUPFILE"

escaped_bam=$(printf '%s\n' "$BAMFILE" | sed 's/[\/&]/\\&/g')
escaped_vcf=$(printf '%s\n' "$VCFFILE" | sed 's/[\/&]/\\&/g')
escaped_pileup=$(printf '%s\n' "$PILEUPFILE" | sed 's/[\/&]/\\&/g')

TMP_CONF="freec_conf_${BASENAME}.conf"

sed -e "s|BAM_PATH_PLACEHOLDER|$escaped_bam|g" \
    -e "s|VCF_PATH_PLACEHOLDER|$escaped_vcf|g" \
    -e "s|PILEUP_PATH_PLACEHOLDER|$escaped_pileup|g" \
    freec_template.conf > $TMP_CONF

echo "Generated config file:"
head -20 $TMP_CONF

freec -conf $TMP_CONF
