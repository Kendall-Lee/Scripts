#!/bin/bash
#SBATCH --job-name=pairtools_hap1
#SBATCH -e pairtools_%J.err
#SBATCH -o pairtools_%J.out
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem=320G
#SBATCH --partition=plant

# --- Load required modules
ml cluster/pairtools
ml samtools/1.19.2-gcc-13.1.0


# 2. Parse alignments to pairs
pairtools parse \
    --no-flip \
    --no-restraint-site \
    --min-mapq 10 \
    --assembly B080 \
    --chroms-path B080_filtered_haps.fasta \
    --out B080_CiFi_parsed.pairs \
    B080_haps_cifi_aln.sorted.bam

# 3. Sort pairs
pairtools sort -t 20 -o B080_CiFi_sorted.pairs  B080_pairs_fixed.pairs


bam_in="B791_hap1.bam"
ref_fa="B791_Hap1_filtered.fasta"

# --- Sort and index the BAM
samtools sort -@ ${SLURM_NTASKS} -o B791_hap1.sorted.bam $bam_in
mv B791_hap1.sorted.bam $bam_in
samtools index $bam_in

# --- Index the reference if not present
samtools faidx $ref_fa

# --- Main pairtools pipeline
samtools view -h -@8 -f 3 -F 256 $bam_in | \
pairtools parse \
  --min-mapq 10 \
  --walks-policy 5any \
  --chroms-path ${ref_fa}.fai | \
pairtools sort --nproc 8 | \
pairtools dedup --mark-dups | \
pairtools select '(pair_type=="UU")' | \
bgzip > B791_hap1.pairs.gz

# --- Index and gather stats
pairix B791_hap1.pairs.gz
pairtools stats B791_hap1.pairs.gz > B791_hap1.pairs.stats
