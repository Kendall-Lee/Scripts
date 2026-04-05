#!/bin/bash
#SBATCH --job-name=GetOrganelle
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/GetOrganelle_%j.out
#SBATCH --error=logs/GetOrganelle_%j.err
#SBATCH --partition=plant
#SBATCH --array=1-829


input_dir=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/All_fastqs
output_base=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/GetOrganelle_out
samples=($(ls ${input_dir}/*_R1.fq.gz))

r1=${samples[$SLURM_ARRAY_TASK_ID-1]}
sample=$(basename "$r1" _R1.fq.gz)
r2=${input_dir}/${sample}_R2.fq.gz
outdir=${output_base}/${sample}

mkdir -p "$outdir"
echo "Running GetOrganelle for $sample"

get_organelle_from_reads.py \
    -1 "$r1" \
    -2 "$r2" \
    -o "$outdir" \
    -F embplant_pt \
    -R 15 \
    -k 21,45,65,85,105 \
    -t $SLURM_CPUS_PER_TASK
