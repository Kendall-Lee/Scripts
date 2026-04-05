#!/bin/bash
#SBATCH --job-name=minimap_B080
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=200gb
#SBATCH --time=60:00:00
#SBATCH --output=minimap_hifi.%j.out
#SBATCH --error=minimap_hifi.%j.error
#SBATCH --partition=highmem

# name variables
# ccs reads (query)
query="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_filtered_haps.fasta"
# reference fasta
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Hifiasm_OmniC/haplotypes/Suziblue_hap1.fa"
# (other commented refs left as-is)
# prefix for output
pre='B080SuziHap1'

# load modules
ml cluster/minimap2/2.26
ml samtools/1.19.2-gcc-13.1.0

# ### to get PAF alignment file from 2 genome - axm20 is mapping to reference that is more divergent, asm5 is least divergent
# #PAF is most useful for dotplot creation in dotplotly
minimap2 -x asm5 -t 32 $ref $query > $pre.paf
#minimap2 -ax asm5 --eqx $ref $query > $pre.sam

# run minimap2 to map ccs reads to reference assembly, output SAM
minimap2 -ax map-hifi $ref $query > $pre.minimap2.sam
#
# # convert SAM to BAM, sort, and save with consistent output name
samtools view -bS $pre.minimap2.sam | samtools sort -o $pre.sorted.bam
#
# # index the sorted BAM file
samtools index $pre.sorted.bam

ml bcftools/1.19-gcc-13.1.0

# samtools faidx $ref
#
# bcftools mpileup -Oz -q 20 -f $ref $pre.minimap2.sorted.bam > $pre.mpileup.vcf.gz
bcftools call -Oz $pre.mpileup.vcf.gz > $pre.call.vcf.gz
# bcftools index $pre.call.vcf.gz

# generate depth file using the correctly named sorted BAM
samtools depth $pre.sorted.bam > $pre.depth.txt

# samtools faidx $ref
#
# ###you are probably going to have to adjust the grep string based on what your chromosomes are called!
# cut -f1,2 Suziblue_renamed_reordered.fa.fai | grep -E "Chr.[12]" > genome.chrom.sizes

# get coverage information from samtools
samtools coverage ${pre}.sorted.bam -o ${pre}_samtools_coverage.txt
## produce histograms instead of tabular output
samtools coverage -m ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist.txt
## produce histograms with 100bp windows
samtools coverage -m -w 100 ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist_100bp_windows.txt



##################
#for Loop
for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Raw_fastqs/Recollect_fastqs/*.gz | sed "s:.PB.fastq.gz::g; s:.*/::g"); do cat minimap_hifi.sh | sed "s:@id:$i:g" > minimap_hifi_"$i".sh; done


############# for short read######

#!/bin/bash
#SBATCH --job-name=mini_coverage
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=60gb
#SBATCH --time=60:00:00
#SBATCH --output=stds/minimap_hifi.%j.out
#SBATCH --error=stds/minimap_hifi.%j.error
#SBATCH --partition=khufu

#query
query="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/CC477_map/indel.fa"
#indexed reference
ref="/cluster/lab/clevenger/hwright/Sameer_Magic/final_asm/CC477final.fa"
#prefix
pre="CC47_smut"

#load bwa
ml cluster/minimap2/2.26
#map
minimap2 -ax asm5 --eqx $ref $query > $pre.sam
samtools view -@ 32 -h $pre.sam | samtools sort -@ 32 -O BAM -o $pre.sorted.bam


minimap2 -x asm5 -t 8 $ref $query > $pre.paf

# load samtools
ml cluster/samtools/1.16.1
samtools view -@ 32 -h $pre._out.sam | samtools sort -@ 32 -O BAM -o $pre.sorted.bam
# use samtools to index bam output and extract alignments for each separate chromosome
samtools index ${pre}.sorted.bam
# get coverage information from samtools
samtools coverage ${pre}.sorted.bam -o ${pre}_samtools_coverage.txt
## produce histograms instead of tabular output
samtools coverage -m ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist.txt
## produce histograms with 100bp windows
samtools coverage -m -w 100 ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist_100bp_windows.txt


for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed | sed "s:_.PB.fastq.gz::g; s:.*/::g"); do cat minimap.sh | sed "s:@id:$i:g" > minimap."$i".sh; done


######### filtered post-khufu 01 for short read
#!/bin/bash
#SBATCH --job-name=filt_coverage
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=60gb
#SBATCH --time=60:00:00
#SBATCH --output=stds/filt_cov.%j.out
#SBATCH --error=stds/filt_cov.%j.error
#SBATCH --partition=plant

#bam files
bam="/cluster/projects/khufu/wiregrass/PROC/003_20240227_Sem2/bams/unique_@id.bam"

#prefix
pre="unique_@id_long"
# load samtools
ml cluster/samtools/1.16.1

samtools sort $bam -@ 32 -O BAM -o $pre.sorted.bam
# use samtools to index bam output and extract alignments for each separate chromosome
samtools index ${pre}.sorted.bam
# get coverage information from samtools
samtools coverage ${pre}.sorted.bam -o ${pre}_samtools_coverage.txt
## produce histograms instead of tabular output
samtools coverage -m ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist.txt
## produce histograms with 100bp windows
samtools coverage -m -w 100 ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist_100bp_windows.txt



for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed | sed "s:.bam::g; s:.*/::g; s:.PB.fastq.gz::g"); do cat filt_coverage.sh | sed "s:@id:$i:g" > filt_coverage_"$i".sh; done



############ bedtools coverage
#!/bin/bash
#SBATCH --job-name=bed_coverage
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=60gb
#SBATCH --time=60:00:00
#SBATCH --output=stds/minimap_hifi.%j.out
#SBATCH --error=stds/minimap_hifi.%j.error
#SBATCH --partition=plant
module load cluster/bedtools/2.28.0

ref='/cluster/home/klee/PacBio_project/ref.fa'
#bam files
bam="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/24.CA.D10.F1.22.cov..sorted.bam"


bedtools genomecov  -i $bam -g $ref
