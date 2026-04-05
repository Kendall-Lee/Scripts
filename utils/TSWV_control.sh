#!/bin/bash
#SBATCH -J TSWV_control
#SBATCH --time=144:00
#SBATCH -c 32
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="120G"


module load cluster/minimap2

fqdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed"
id="@id"
query="$fqdir"/$id".PB.fastq.gz"
ref="/cluster/lab/clevenger/KLee/Ethan_Share/NCChr1.fa"


minimap2 -ax map-hifi $ref $query > $id.TSWV_region_compare.minimap.bam

#Short read
# Load necessary modules
module load cluster/bwa/0.7.17
module load samtools/1.19.2-gcc-13.1.0



fqdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short"
id="@id"
R1="$fqdir"/$id"_R1.fq.gz"
R2="$fqdir"/$id"_R2.fq.gz"
ref="Regions_500kb.fa"

# Run BWA alignment
#bwa mem -t 8 $ref $R1 $R2 > $id.TSWV_region_compare.bwa.bam

#########################################################################
module load samtools/1.19.2-gcc-13.1.0

# Purpose: Filter, sort, index, and compute mapping fractions MQ>30
# Input: compare.minimap.bam
# Output: MQ30-sorted BAM, idxstats, and fraction summary


inbam="$id.TSWV_region_compare.bwa.bam"
prefix="$id.TSWV_region_compare.bwa"

# 1. Filter MQ>30, sort
samtools view -b -F 2304 -q 30 "$inbam" \
  | samtools sort -o "${prefix}.MQ30.sorted.bam" -

# 2. Keep only reads with ≥98% aligned portion
# samtools view -h "${prefix}.MQ30.sorted.bam" \
# | awk '
#   /^@/ {print; next}
#   {
#     cigar = $6
#     qlen  = length($10)
#     m = 0
#     while (match(cigar, /[0-9]+[A-Z]/)) {
#       L  = substr(cigar, RSTART, RLENGTH-1)
#       op = substr(cigar, RSTART + RLENGTH - 1, 1)
#       if (op=="M" || op=="=" || op=="X") m += L
#       cigar = substr(cigar, RSTART + RLENGTH)
#     }
#     if (qlen > 0 && m/qlen >= 0.7) print
#   }' \
# | samtools view -b -o "${prefix}.MQ30.sorted.best70.bam"



samtools index "${prefix}.MQ30.sorted.bam"

# 2️⃣ Generate idxstats
samtools idxstats "${prefix}.MQ30.sorted.best98.bam" > "${prefix}.MQ30.sorted.best98.bam.stats"

# 3️⃣ Compute total mapped and per-region fractions
awk '
   $1!="*" { total += $3; data[$1]=$0 }
   END {
       print "ref_name","length","mapped_reads","fraction_of_total";
       for (r in data) {
           split(data[r], f)
           frac = f[3]/total
           printf "%s\t%s\t%s\t%.6f\n", f[1], f[2], f[3], frac
       }
   }
' "${prefix}.MQ30.sorted.best98.bam.stats" > "${prefix}.fraction.txt"






########################################
for i in $(ls $fqdir/*_R1.fq.gz | sed "s:.*/::; s:_R1.fq.gz::g"); do cat ./samtools.sh | sed "s:@id:$i:g" > samtools_"$i".sh; done




inbam="NC_control.TSWV_region_compare.minimap.bam"
prefix="NC_control.TSWV_region_compare"




# 1. Filter MQ>30, sort
samtools view -b -F 2304 -q 30 "$inbam" \
  | samtools sort -o "${prefix}.MQ30.sorted.bam" -

# 2. Keep only reads with ≥98% aligned portion
samtools view -h "${prefix}.MQ30.sorted.bam" \
| awk '
  /^@/ {print; next}
  {
    cigar = $6
    qlen  = length($10)
    m = 0
    while (match(cigar, /[0-9]+[A-Z]/)) {
      L  = substr(cigar, RSTART, RLENGTH-1)
      op = substr(cigar, RSTART + RLENGTH - 1, 1)
      if (op=="M" || op=="=" || op=="X") m += L
      cigar = substr(cigar, RSTART + RLENGTH)
    }
    if (qlen > 0 && m/qlen >= 0.98) print
  }' \
| samtools view -b -o "${prefix}.MQ30.sorted.best98.bam"



samtools index "${prefix}.MQ30.sorted.best98.bam"

# 2️⃣ Generate idxstats
samtools idxstats "${prefix}.MQ30.sorted.best98.bam" > "${prefix}.MQ30.sorted.best98.bam.stats"

# 3️⃣ Compute total mapped and per-region fractions
awk '
   $1!="*" { total += $3; data[$1]=$0 }
   END {
       print "ref_name","length","mapped_reads","fraction_of_total";
       for (r in data) {
           split(data[r], f)
           frac = f[3]/total
           printf "%s\t%s\t%s\t%.6f\n", f[1], f[2], f[3], frac
       }
   }
' "${prefix}.MQ30.sorted.best98.bam.stats" > "${prefix}.fraction.txt"
