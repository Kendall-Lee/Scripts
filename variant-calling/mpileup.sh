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

# Load samtools
ml samtools/1.19.2-gcc-13.1.0

REF="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Hifiasm_OmniC/haplotypes/Suziblue_hap1.fa"
BAM_DIR="/cluster/lab/clevenger/KLee/Dosage_testing/RE_bwa"
OUT_DIR="/cluster/lab/clevenger/KLee/Dosage_testing/RE_bwa/FreeC"

mkdir -p "$OUT_DIR"

# Get the BAM file for this task ID
bam_files=("$BAM_DIR"/*.bam)
bam=${bam_files[$SLURM_ARRAY_TASK_ID-1]}  # Array indices start at 1, bash at 0

base=$(basename "$bam" .bam)
bed="$OUT_DIR/${base}.snp.bed"

if [[ ! -f "$bed" ]]; then
    echo "BED file $bed not found for $base, skipping..."
    exit 1
fi

echo "Running samtools mpileup for $base"

if ! samtools mpileup -f "$REF" -l "$bed" "$bam" > "$OUT_DIR/${base}.bam_minipileup.pileup"; then
    echo "Error: samtools mpileup failed for $base" >&2
    exit 1
fi

echo "Done $base"
