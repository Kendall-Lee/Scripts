#!/bin/bash

ml samtools/1.19.2-gcc-13.1.0


TARGETS=AllProbesSuzi.filtered.bed # your BED file of target regions
OUT=Trinity_off_target_stats.tsv

echo -e "Sample\tTotalReads\tOnTargetReads\tOffTargetPercent" > $OUT

for bam in ./Trinity_Suzi_bams/*.bam; do
    sample=$(basename $bam .bam)

    # total mapped reads (count all alignments)
    total=$(samtools view -c $bam)

    # on-target mapped reads
    on_target=$(samtools view -c -L $TARGETS $bam)

    # off-target percent
    off_target=$(awk -v on=$on_target -v tot=$total 'BEGIN { if (tot > 0) print (1 - on/tot) * 100; else print "NA" }')

    echo -e "${sample}\t${total}\t${on_target}\t${off_target}" >> $OUT
done

##############stricter #
# Where -F 0x904 means:
# -F 0x4 exclude unmapped
# -F 0x100 exclude secondary
# -F 0x800 exclude supplementary


#!/bin/bash
ml samtools/1.19.2-gcc-13.1.0

TARGETS=AllProbesSuzi.filtered.bed
OUT=Trinity_off_target_stats.tsv
echo -e "Sample\tTotalMapped\tOnTarget\tOffTargetPercent" > $OUT

for bam in ./Trinity_Suzi_bams/*.bam; do
    sample=$(basename "$bam" .bam)

    # Count primary mapped reads only
    total=$(samtools view -c -F 0x904 "$bam")

    # On-target mapped reads (primary only)
    on_target=$(samtools view -c -F 0x904 -L "$TARGETS" "$bam")

    # Off-target % calculation
    off_target=$(awk -v on=$on_target -v tot=$total 'BEGIN { if (tot > 0) printf "%.2f", (1 - on/tot)*100; else print "NA" }')

    echo -e "${sample}\t${total}\t${on_target}\t${off_target}" >> "$OUT"
done
