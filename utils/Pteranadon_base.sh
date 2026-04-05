#!/bin/bash
#SBATCH -J pteran_B791
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="64G"

ml cluster/bwa/0.7.17

# t="24"
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Hifiasm_OmniC/haplotypes/Suziblue_hap1.fa"
query="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Assembly/Haps/B791_haps.fasta"
out="B791_scaffSuziHap1"
SegLen=1000
MinQueryLen=5
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source "$khufu_dir"/utilities/load_modules.sh
source /cluster/projects/khufu/korani_projects/KhufuEnv/KhufuEnv.sh

/cluster/projects/khufu/korani_projects/Pteranodon/scripts/PteranodonBase.sh  -ref $ref -query $query -o $out -SegLen $SegLen -MinQueryLen $MinQueryLen -t 24

#   -/-o  the output folder and prefix
#   -/--SegLen  query sequences are split into  segments of this size in bases
#   -/--MinQueryLen  query sequences less than this this megabases are excluded
#   -/--ScafPer  query seqeunces less than this percentage out of ref matches are excluded


#!/bin/bash
#SBATCH -J pteranadon3
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="100G"
# ========== Load Modules ==========
ml cluster/bwa/0.7.17
ml gcc/13.1.0
ml bcftools/1.19
ml samtools/1.19.2
ml gcc/13.1.0
ml r/4.1.2
ml htslib/1.19.1
# ========== Define paths ==========
ref="/cluster/lab/clevenger/VPerez/Horse_Assembly/ncbi_dataset/data/GCF_041296265.1/GCF_041296265.1_TB-T2T_genomic.fna"
query="/cluster/lab/clevenger/VPerez/Horse_Assembly/New_m84238_250614_102330_s3.hifi_reads.hifiasm.bp.p_ctg.fa"
out="HAssembly_Pteranodon3"
SegLen=1000
MinQueryLen=1.5
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source "$khufu_dir"/utilities/load_modules.sh
source /cluster/projects/khufu/korani_projects/KhufuEnv/KhufuEnv.sh
/cluster/projects/khufu/korani_projects/Pteranodon/scripts/PteranodonBase.sh -ref $ref -query $query -o $out -SegLen $SegLen -MinQueryLen $MinQueryLen -t 24 -auto 1
