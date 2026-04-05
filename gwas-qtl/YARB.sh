#!/bin/bash
#SBATCH --job-name=yarb
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=480gb
#SBATCH -c 16
#SBATCH --time=400:00:00
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"

source ~/miniforge3/etc/profile.d/conda.sh
conda activate yarbs

#id="@id"
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
query="/cluster/lab/clevenger/KLee/CiFi/YAHS_noOmniC/B080_block1.fa"
out="B080_block1"

python minimap_prep.py -r $ref -q $query -o $out


python scaffold.py \
  -q $query \
  -c B100_suzihap1_scaff.coords \
  -m scaffolding_2025-12-05_825969200.json \
  -o $out \
  -g 100




#pull out only chr and sort into haps

module load samtools/1.19.2-gcc-13.1.0
zcat_or_cat="cat"   # or zcat if file is gzipped

for hap in 1 2 3 4; do
  $zcat_or_cat B278_suzihap1_scaff_scaffolded.fasta \
  | awk -v h=$hap '
      /^>/ {
          # check if this is a scaffold
          if ($0 ~ /^>scaffold_/) { keep=0; next }
          # extract the ".#" part of the chromosome name
          if (match($1, /^>Chr[0-9]+\.([0-9]+)/, a)) {
              keep = (a[1] == h)
          } else { keep=0 }
      }
      keep { print }
  ' > B278_hap${hap}.fa
done

#rename
for f in B278_hap*.fa; do
  awk '/^>/{match($1, /^>(Chr[0-9]+\.[0-9]+)/, a); print ">" a[1]; next} {print $0}' "$f" > tmp && mv tmp "$f"
done
