#!/bin/bash
#SBATCH -J pankmer_matrix
#SBATCH --time=96:00:00
#SBATCH -c 16
#SBATCH -N 1
#SBATCH -p highmem
#SBATCH -o "stds/stdout_pankmer_matrix"
#SBATCH -e "stds/stderr_pankmer_matrix"
#SBATCH --mem="400G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL

eval "$(conda shell.bash hook)"
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/anaconda3/envs/pankmer


# set prefix for output
pre='FM_hallie'
# working dir path
# clean FASTA-only dir
wd='/cluster/lab/clevenger/hwright/fingermillet/longread/renamed_fq'
fa_dir="${wd}/fa"

pankmer index -g ${fa_dir} -o ${wd}/${pre}_index.tar -t 16
pankmer adj-matrix -i ${wd}/${pre}_index.tar -o ${wd}/${pre}_adj_matrix.csv
pankmer clustermap -i ${wd}/${pre}_adj_matrix.csv -o ${wd}/${pre}_adj_matrix.svg
pankmer count -i ${wd}/${pre}_index.tar > ${wd}/${pre}_conservation_count.txt
pankmer collect --conf -i ${wd}/${pre}_index.tar -o ${wd}/${pre}_collect.svg










pankmer adj-matrix -i SHB_Full_index.tar -o SHB_adj_matrix.tsv

#pankmer similarity  -i SHB_adj_matrix.tsv -o simmatrix.tsv




for i in {02..12}; do
  echo "Processing Chr.${i}.1..."
  pankmer anchor-genome -i SHB_Full_index.tar \
    -a Suziblue_renamed.fa \
    -c Chr.${i}.1 \
    --table ./Anchor/Suziblue/Suziblue_anchor.tsv \
    -o ./Anchor/Suziblue/Suzi_Chr.${i}.1_anchor.svg
done



# pankmer anchor-genome -i SHB_Full_index.tar \
#   -a Suziblue_renamed.fa \
#   -c Chr.02.1 \
#   --table ./Anchor/Suziblue/Suziblue_anchor.tsv \
#   -o ./Anchor/Suziblue/Suzi_Chr.02.1_anchor.svg









# pankmer index -g /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/Full_genomes/*.fa -o /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Pankmer/SHB_Full_index.tar
#
#
# # set prefix for output
# pre='SHB_Full'
# # working dir path
# wd='/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Pankmer'
#
# # build a kmer index using all fasta files in a directory (following -g)
# #pankmer index -g ${wd} -o ${wd}/${pre}_index.tar -t 8# generate an adjacency matrix with that output
# pankmer adj-matrix -i ${wd}/${pre}_index.tar -o ${wd}/${pre}_adj_matrix.csv
# # plot a clustered heatmap
# pankmer clustermap -i ${wd}/${pre}_adj_matrix.csv -o ${wd}/${pre}_adj_matrix.svg
# # count the number of kmers at each conservation level (ie, kmers present in X number of the total samples)
# pankmer count -i ${wd}/${pre}_index.tar > ${wd}/${pre}_counservation_count.txt
# # calculate collection curve and plot with 95% confidence intervals
# pankmer collect --conf -i ${wd}/${pre}_index.tar -o ${wd}/${pre}_collect.svg

# #BGZIP anchor fastas
# ml cluster/samtools/1.16.1
# ml htslib/1.19.1-gcc-13.1.0
# bgzip ./Anchor/Suziblue_hap1.fa > ./Anchor/Suziblue_hap1.fa.gz
#
# # build an Anchor Map
# pankmer anchormap -t 8 -i ${wd}/${pre}_index.tar \
#   -o ${wd}/${pre}_anchormap \
#   --anchors PAR_anchors/*.fa.gz \
#   --anno PAR_anchors/features/*
#
# # view anchor map
# pankmer view ${wd}/${pre}_anchormap/
#

# 1. Create a directory
mkdir -p ./Anchor/Suziblue

# 2. Run region anchoring
pankmer anchor-region \
  -i SHB_Haps_Pankmer_primary_index.tar \
  -a ./Anchor/Suziblue_hap1.fa \
  -c Chr.01:1-49039693 \ #refer to .fai file for coords
  > ./Anchor/Suziblue/Suziblue_Chr.01.bdg


#Plot with gtracks
#!/bin/bash
#SBATCH -J gtracks
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p plant
#SBATCH -o "stds/stdout_gtracks"
#SBATCH -e "stds/stderr_gtracks"
#SBATCH --mem="200G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL
ml cluster/bedtools/2.28.0
module load cluster/python/3.11.1
. /cluster/home/klee/gtracks_env/bin/activate
gtracks-gff3-to-bed12 /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/Liftoff/Suziblue_hap1.gffread.gff3 | bgzip -c > ./Anchor/Suziblue/Suziblue_hap1.gffread.bed.gz
cd ./Anchor/Suziblue/
gtracks --max 100 --genes Suziblue_hap1.gffread.bed.gz Chr.01:1-49039693 Suziblue_Chr.01.bdg Suziblue_Chr.01.svg



pankmer anchor-genome -i SHB_Full_index.tar \
  -a /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/Full_genomes/Suziblue.fa \
  -c Chr01 \
  --table ./Anchor/Suziblue/Suziblue_anchor.tsv \
  -o ./Anchor/Suziblue/Sp9509_Chr19_anchor.svg
