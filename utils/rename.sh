#!/bin/bash
#SBATCH -J rename_headers
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"
###############

sed -i 's:>chr04_fixed04:>ICG1471.Chr.04:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr05_fixed05:>ICG1471.Chr.05:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr06_fixed06:>ICG1471.Chr.06:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr08_fixed08:>ICG1471.Chr.08:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr10_fixed10:>ICG1471.Chr.10:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr11_fixed11:>ICG1471.Chr.11:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr13_fixed13:>ICG1471.Chr.13:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr14_fixed14:>ICG1471.Chr.14:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr15_fixed15:>ICG1471.Chr.15:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr19_fixed19:>ICG1471.Chr.19:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
sed -i 's:>chr20_fixed20:>ICG1471.Chr.20:g' ICG1471_hifiasm_hic_revision1_pteranodon.fa
