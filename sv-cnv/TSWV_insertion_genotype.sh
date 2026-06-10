#!/bin/bash
#SBATCH -J TSWV_insertion
#SBATCH --time=144:00
#SBATCH -c 32
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem="120G"
#SBATCH -o "stds/stdout_%x_%A_%a.out"
#SBATCH -e "stds/stderr_%x_%A_%a.err"
#SBATCH --array=1-136
###############################################################################
# Genotype the TSWV resistance insertion locus by computing per-region mapping
# fractions from HiFi reads aligned to the TSWV region reference (NCChr1.fa).
#
# Strategy: reads that span the insertion align to the insert-containing contig;
# reads from susceptible lines align only to flanking sequence. The fraction of
# total mapped reads landing on each region is used to classify lines as
# carrying or lacking the insertion.
#
# Filters applied:
#   - MQ > 30  (unique alignment)
#   - ≥ 98% of read length aligned (excludes partial/chimeric alignments)
#
# Sample list: samples_MAGIC.txt (one ID per line, matching fastq prefix)
# Output per sample: <id>.TSWV.fraction.txt
###############################################################################

module load cluster/minimap2
module load samtools/1.19.2-gcc-13.1.0

fqdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed"
ref="/cluster/lab/clevenger/KLee/Ethan_Share/NCChr1.fa"

id=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples_MAGIC.txt)
query="${fqdir}/${id}.PB.fastq.gz"
prefix="${id}.TSWV"

# ── 1. Align HiFi reads to TSWV region reference ─────────────────────────────
minimap2 -ax map-hifi -t "$SLURM_JOB_CPUS_PER_NODE" \
    "$ref" "$query" \
    > "${prefix}.minimap.bam"

# ── 2. Filter: MQ>30, remove secondary/supplementary ─────────────────────────
samtools view -b -F 2304 -q 30 "${prefix}.minimap.bam" \
    | samtools sort -o "${prefix}.MQ30.sorted.bam" -
samtools index "${prefix}.MQ30.sorted.bam"

# ── 3. Filter: keep only reads with ≥98% of query length aligned ──────────────
# Counts M/=/X CIGAR operations; discards reads where aligned bases < 98% of
# query length. This removes reads that partially overlap the region without
# spanning the insertion breakpoint.
samtools view -h "${prefix}.MQ30.sorted.bam" \
| awk '
    /^@/ { print; next }
    {
        cigar = $6; qlen = length($10); m = 0
        while (match(cigar, /[0-9]+[A-Z]/)) {
            L  = substr(cigar, RSTART, RLENGTH-1)
            op = substr(cigar, RSTART + RLENGTH - 1, 1)
            if (op=="M" || op=="=" || op=="X") m += L
            cigar = substr(cigar, RSTART + RLENGTH)
        }
        if (qlen > 0 && m/qlen >= 0.98) print
    }' \
| samtools view -b -o "${prefix}.MQ30.best98.bam"
samtools index "${prefix}.MQ30.best98.bam"

# ── 4. Compute per-region mapping fractions ───────────────────────────────────
samtools idxstats "${prefix}.MQ30.best98.bam" \
    > "${prefix}.MQ30.best98.idxstats"

awk -v sample="$id" '
    $1!="*" { total += $3; data[$1]=$0 }
    END {
        printf "sample\tref_name\tlength\tmapped_reads\tfraction_of_total\n"
        for (r in data) {
            split(data[r], f)
            frac = (total > 0) ? f[3]/total : 0
            printf "%s\t%s\t%s\t%s\t%.6f\n", sample, f[1], f[2], f[3], frac
        }
    }
' "${prefix}.MQ30.best98.idxstats" > "${prefix}.fraction.txt"
