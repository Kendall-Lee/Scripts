#######################################################
### run bcftfools norm to split multiallelic sites#####
######################################################
#!/bin/bash
#SBATCH --job-name=Rscript_2_full
#SBATCH -e Rscript_2_full.R_%J.err
#SBATCH -o Rscript_2_full.R_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=normal
#SBATCH --array=1-637

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0


bcftools view \
-i 'F_MISSING<=0.4' \
-Oz \
-o merged_pan.withDS.maxmiss40.vcf.gz \
merged_pan.withDS.vcf.gz


bcftools index -f merged_pan.withDS.maxmiss40.vcf.gz


### loop to merge in batches
# Create a list of all files
files=( *filtered.vcf.split.vcf.withDS.vcf.gz )

# Batch size
batch_size=10
total=${#files[@]}

# Counter for batch files
batch_num=1

for ((i=0; i<total; i+=batch_size)); do
    batch_files=( "${files[@]:i:batch_size}" )
    batch_output="merged_batch_${batch_num}.vcf.gz"
    echo "Merging batch $batch_num -> $batch_output"
    bcftools merge "${batch_files[@]}" -Oz -o "$batch_output"
    bcftools index -f "$batch_output"
    ((batch_num++))
done







################################################################



FILE=$(ls *.filtered.vcf | sed -n "${SLURM_ARRAY_TASK_ID}p")

bcftools norm -m -any $FILE |
bgzip -c > ${FILE%.vcf.gz}.split.vcf.gz

bcftools index -f ${FILE%.vcf.gz}.split.vcf.gz

# one test sample
bcftools norm -m -any -Oz -o B001.split.vcf.gz B001.filtered.vcf.gz
tabix B001.split.vcf.gz


#############run ###################
ls ./filtered_split_vcfs/*.vcf.gz | parallel -j 20 \
'./add_DS_stream.py {} {.}.withDS.vcf && bgzip -f {.}.withDS.vcf && tabix -p vcf {.}.withDS.vcf.gz'

##################### compresss files #########
bgzip -f test.vcf
tabix -p vcf test.vcf.gz

#final sanity check
bcftools query -f '[%DS\n]' *.withDS.vcf.gz | head


####################################################################################################################################
####################################################################################################################################
################################################ full pipeline #####################################################################
####################################################################################################################################
####################################################################################################################################

#!/bin/bash
set -euo pipefail

############################################
# USER SETTINGS
############################################

PLOIDY=4
THREADS=20
MIN_DP=8

############################################
# STEP 1 — Split multiallelic sites
############################################

echo "Splitting multiallelic sites..."

ls *.filtered.vcf.gz | parallel -j $THREADS '
bcftools norm -m -any {} |
bgzip -c > {.}.split.vcf.gz &&
bcftools index -f {.}.split.vcf.gz
'

############################################
# STEP 2 — Add DS field (AD-derived dosage)
############################################

echo "Adding DS field..."

cat << 'EOF' > add_DS_stream.py
#!/usr/bin/env python3
import sys
import gzip

ploidy = int(sys.argv[3])
min_dp = int(sys.argv[4])

infile = sys.argv[1]
outfile = sys.argv[2]

with gzip.open(infile, 'rt') as fin, open(outfile, 'w') as fout:
    for line in fin:
        if line.startswith("##"):
            fout.write(line)

        elif line.startswith("#CHROM"):
            fout.write(f'##FORMAT=<ID=DS,Number=1,Type=Float,Description="AD-derived dosage ({ploidy}*ALT/DP)">\n')
            fout.write(line)

        else:
            fields = line.rstrip().split("\t")
            format_fields = fields[8].split(":")

            if "DP" not in format_fields or "AD" not in format_fields:
                fout.write(line)
                continue

            dp_index = format_fields.index("DP")
            ad_index = format_fields.index("AD")

            fields[8] = fields[8] + ":DS"
            new_samples = []

            for sample in fields[9:]:
                vals = sample.split(":")

                if vals[dp_index] == "." or vals[ad_index] == ".":
                    new_samples.append(sample + ":.")
                    continue

                dp = float(vals[dp_index])
                if dp < min_dp:
                    new_samples.append(sample + ":.")
                    continue

                ad_vals = vals[ad_index].split(",")

                if dp > 0 and len(ad_vals) >= 2:
                    alt = float(ad_vals[1])
                    ds = round(ploidy * alt / dp, 4)
                else:
                    ds = "."

                new_samples.append(sample + ":" + str(ds))

            fields[9:] = new_samples
            fout.write("\t".join(fields) + "\n")
EOF

chmod +x add_DS_stream.py

ls *.split.vcf.gz | parallel -j $THREADS '
./add_DS_stream.py {} {.}.withDS.vcf '"$PLOIDY"' '"$MIN_DP"' &&
bgzip -f {.}.withDS.vcf &&
bcftools index -f {.}.withDS.vcf.gz
'

#can also run like
PLOIDY=4
MIN_DP=3

for vcf in vcfs_bgzip/*.vcf.gz; do
    base=${vcf%.vcf.gz}

    ./add_DS_stream.py "$vcf" "${base}.withDS.vcf" $PLOIDY $MIN_DP

    bgzip -f "${base}.withDS.vcf"
    bcftools index -f "${base}.withDS.vcf.gz"
done

############################################
# STEP 3 — Merge samples and filter merged file
############################################

echo "Merging VCFs..."

bcftools merge *.withDS.vcf.gz -Oz -o merged_pan.withDS.vcf.gz
bcftools index -f merged_pan.withDS.vcf.gz


# 1. Keep only biallelic variants (but ALL types)
bcftools view -m2 -M2 merged.withDS.vcf.gz -Oz -o step1.biallelic.vcf.gz

# 2. Add allele frequency + missingness
bcftools +fill-tags step1.biallelic.vcf.gz \
-Oz -o step2.tags.vcf.gz -- -t AF,F_MISSING

# 3. Filter for quality, AF, missingness
bcftools view -i 'QUAL>=30 && AF>=0.05 && AF<=0.95 && F_MISSING<=0.2' \
step2.tags.vcf.gz -Oz -o final.for_dosage.vcf.gz

bcftools index -f final.for_dosage.vcf.gz


############################################
# STEP 4 — Convert to dosage matrix
############################################

echo "Converting to dosage matrix..."

vcf2dosage.R --field DS merged_pan.withDS.vcf.gz

echo "Pipeline complete."
