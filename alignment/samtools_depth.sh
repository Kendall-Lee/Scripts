#!/bin/bash
#SBATCH -J samtools_depth
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p normal
#SBATCH -o "stds/stdout_depth"
#SBATCH -e "stds/stderr_depth"
#SBATCH --mem="200G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL


ml samtools/1.19.2-gcc-13.1.0

#!/bin/bash
# make sure the output directory exists
outdir=/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/PerSite
mkdir -p "$outdir"

# short‑read downsampled BAMs
samtools depth -a sub_W.2024.SP.CA.D12.F1.26.0.5x.bam \
  > ${outdir}/sub_W.2024.SP.CA.D12.F1.26_short_0.5x.depth

samtools depth -a sub_W.2024.SP.CA.D12.F1.26.1x.bam \
  > ${outdir}/sub_W.2024.SP.CA.D12.F1.26_short_1x.depth

samtools depth -a sub_W.2024.SP.CA.D12.F1.26.2x.bam \
  > ${outdir}/sub_W.2024.SP.CA.D12.F1.26_short_2x.depth


# long‑read (PacBio/HiFi) downsampled BAMs
samtools depth -a sub_W.2024.SP.CA.D12.F1.26.PB.0.5x.LRLP.sorted.bam \
  > ${outdir}/sub_W.2024.SP.CA.D12.F1.26_long_0.5x.depth

samtools depth -a sub_W.2024.SP.CA.D12.F1.26.PB.1x.LRLP.sorted.bam \
  > ${outdir}/sub_W.2024.SP.CA.D12.F1.26_long_1x.depth

samtools depth -a sub_W.2024.SP.CA.D12.F1.26.PB.2x.LRLP.sorted.bam \
  > ${outdir}/sub_W.2024.SP.CA.D12.F1.26_long_2x.depth

# ---------------------------
# SRLP  FILTERED
samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/RedoMergedShort/Filtered/Filtered_Coverage/unique_W.2024.SP.CA.D12.F1.26_short.sorted.bam \
  > ${outdir}/W.2024.SP.CW.D4.F1.26_short_filtered.depth

samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/RedoMergedShort/Filtered/Filtered_Coverage/unique_W.2024.SP.HL.D1.F1.06_short.sorted.bam \
  > ${outdir}/W.2024.SP.HL.D1.F1.06_short_filtered.depth

samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/RedoMergedShort/Filtered/Filtered_Coverage/unique_W.2024.SP.HCCA.D1.F1.04_short.sorted.bam \
  > ${outdir}/W.2024.SP.HCCA.D1.F1.04_short_filtered.depth

# # ---------------------------
# LRLP  UNFILTERED
#samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Unfiltered_Long/W.2024.SP.HL.D1.F1.06.cov..sorted.bam.gz \
  > ${outdir}/W.2024.SP.HL.D1.F1.06_long_unfiltered.depth

samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Unfiltered_Long/CA.D12.F1.26.cov..sorted.bam \
  > ${outdir}/CA.D12.F1.26_long_unfiltered.depth

samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Unfiltered_Long/24.HCCH.D1.04.cov..sorted.bam \
  > ${outdir}/24.HCCH.D1.04_long_unfiltered.depth

# ---------------------------
# LRLP  FILTERED
samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Filtered/unique_SP.HL.F1.06_long.sorted.bam \
  > ${outdir}/SP.HL.F1.06_long_filtered.depth

samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Filtered/unique_CA.D12.F1.26_long.sorted.bam \
  > ${outdir}/CA.D12.F1.26_long_filtered.depth

samtools depth -a \
  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/ReDoOctober/bams/unique_W.2024.SP.HCCA.D1.F1.04.dup.bam \
  > ${outdir}/W.2024.SP.HCCA.D1.F1.04_long_filtered.depth


####### Loop to get counts per depth level for hist plotting #####################
  #!/bin/bash
  indir=/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/PerSite
  cd "$indir" || exit

  for f in *.depth; do
      base=${f%.depth}
      echo "Processing $f …"
      awk '{c[$3]++} END{for(d in c) print d, c[d]}' "$f" > "${base}.hist"
  done

  echo "All histograms created in $indir"


##### sub sampling with khufu env ###

# 1x
fastqSubSampling W.2024.SP.CA.D12.F1.26_R1.fq.gz W.2024.SP.CA.D12.F1.26_R2.fq.gz 2538251598
fastqSubSampling W.2024.SP.CA.D12.F1.26.PB.fastq.gz "" 2538251598
#.5x
fastqSubSampling W.2024.SP.CA.D12.F1.26_R1.fq.gz W.2024.SP.CA.D12.F1.26_R2.fq.gz 1269125799
fastqSubSampling W.2024.SP.CA.D12.F1.26.PB.fastq.gz "" 1269125799
#2x
fastqSubSampling W.2024.SP.CA.D12.F1.26_R1.fq.gz W.2024.SP.CA.D12.F1.26_R2.fq.gz 5076503196
fastqSubSampling W.2024.SP.CA.D12.F1.26.PB.fastq.gz "" 5076503196



096: fastqSubSampling $fq1 $fq2 $len > two zipped files, prefix sub_$fq1 & prefix_$fq2
2538251598
