#!/bin/bash

###This script matches two bam files with the same basename and downsamples the total reads of the higher yielding bam
#it outputs:
#1. Normalized bams + the matching bam
#2. read_counts.tsv
#3. normalization_log.tsv

# Directories
NOVADIR="/cluster/lab/clevenger/KLee/Trinity_data/Kendall_bams"
TRINDIR="/cluster/lab/clevenger/KLee/Trinity_data/Trinity_Suzi_bams"
OUTDIR="/cluster/lab/clevenger/KLee/Trinity_data/Normalized/Normalized_bams"
mkdir -p $OUTDIR

# Files
COUNTS=$OUTDIR/read_counts.tsv
LOG=$OUTDIR/normalization_log.tsv

# Reset outputs
echo -e "Sample\tSequencer\tReads" > $COUNTS
echo -e "Sample\tDownsampled\tFraction\tTargetReads\tStatus" > $LOG

# Collect read counts
for bam in $NOVADIR/*.e.bam; do
    sample=$(basename "$bam" .e.bam)
    total=$(samtools view -c "$bam")
    echo -e "${sample}\tNovaSeq\t${total}" >> $COUNTS
done

for bam in $TRINDIR/*.trinity.bam; do
    sample=$(basename "$bam" .trinity.bam)
    total=$(samtools view -c "$bam")
    echo -e "${sample}\tTrinity\t${total}" >> $COUNTS
done

# Match samples present in both
cut -f1 $COUNTS | sort | uniq -c | awk '$1==2{print $2}' | while read sample; do
    nova=$(awk -v s=$sample '$1==s && $2=="NovaSeq"{print $3}' $COUNTS)
    trin=$(awk -v s=$sample '$1==s && $2=="Trinity"{print $3}' $COUNTS)

    # Skip if missing
    [ -z "$nova" ] || [ -z "$trin" ] && continue

    # Pick smaller as target
    if [ "$nova" -lt "$trin" ]; then
        target=$nova
        frac=$(awk -v t=$target -v n=$trin 'BEGIN{print t/n}')
        inbam=$TRINDIR/${sample}.trinity.bam
        outbam=$OUTDIR/${sample}.Trinity.norm.bam
        downsampled="Trinity"
    else
        target=$trin
        frac=$(awk -v t=$target -v n=$nova 'BEGIN{print t/n}')
        inbam=$NOVADIR/${sample}.e.bam
        outbam=$OUTDIR/${sample}.NovaSeq.norm.bam
        downsampled="NovaSeq"
    fi

    # Skip very tiny targets (<100000 reads for safety)
    if [ "$target" -lt 100000 ]; then
        echo -e "${sample}\t${downsampled}\tNA\t${target}\tSKIPPED(low_reads)" >> $LOG
        continue
    fi

    # Clean up fraction for samtools (-s needs 42.xxxxx, not 42.0.xxxxx)
    frac_nolead=$(echo $frac | sed 's/^0*\.//')

    echo "Downsampling ${downsampled} $sample to $target reads ($frac fraction)"

    # Perform downsampling
    samtools view -s 42.${frac_nolead} -b $inbam > $outbam
    samtools index $outbam

    # Copy the other BAM unchanged
    if [ "$downsampled" == "Trinity" ]; then
        cp $NOVADIR/${sample}.e.bam $OUTDIR/${sample}.NovaSeq.norm.bam
        samtools index $OUTDIR/${sample}.NovaSeq.norm.bam
    else
        cp $TRINDIR/${sample}.trinity.bam $OUTDIR/${sample}.Trinity.norm.bam
        samtools index $OUTDIR/${sample}.Trinity.norm.bam
    fi

    # Log
    echo -e "${sample}\t${downsampled}\t${frac}\t${target}\tOK" >> $LOG
done
