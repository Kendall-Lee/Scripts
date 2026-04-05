#!/bin/bash
#SBATCH -J bed
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%Jmerge"
#SBATCH -e "stds/stderr_%x_%Jmerge"
#SBATCH --mem="92G"

module load cluster/bedtools/2.28.0   # if running on the cluster
ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0


# Intersect the probe bed with all variants in the VCF
bedtools intersect -a AllProbesSuzi.pad5.bed \
                   -b PAN_DS_merged.bi.tags.qual.vcf.gz -wa -wb > probes_PAN_DS_merged.PAD.tsv

awk '{print $7"\t"$8-1"\t"$8}' probes_PAN_DS_merged.PAD.tsv | sort -u > probe_variants.PAD.bed

bcftools view -R probe_variants.PAD.bed -Oz -o PAN_DS_probeSubset.PAD.vcf.gz PAN_DS_merged.bi.tags.qual.vcf.gz
bcftools index PAN_DS_probeSubset.PAD.vcf.gz

bcftools +fill-tags PAN_DS_probeSubset.PAD.vcf.gz -- -t F_MISSING > PAN_DS_merged.bi.tags.qual_missingness_per_probe_site.tsv
