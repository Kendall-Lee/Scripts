#!/bin/bash
#SBATCH -e FCS_GX_%j.err
#SBATCH -o FCS_GX_%j.out
#SBATCH --job-name=FCS_GX
#SBATCH --time-min=120:00:00
#SBATCH --ntasks=16
#SBATCH --mem=128G
#SBATCH --partition=khufu
#SBATCH --nodes=1

module load cluster/singularity

fasta="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B591/B591.asm.bp.p_ctg.fa"

export FCS_DEFAULT_IMAGE=/cluster/home/klee/fcs-gx.sif

/cluster/home/klee/fcs.py --image /cluster/home/klee/fcs-gx.sif screen genome --fasta $fasta --tax-id 13749 --gx-db /cluster/home/scarey/packages/FCS-GX_v0.4.0/gxdb --out-dir Contamination_Check




cat $fasta | python3 /cluster/home/klee/fcs.py  clean genome --action-report ./Contamination_Check/B278_fcs_gx_report.txt --output clean.fasta --contam-fasta-out contam.fasta
