#!/bin/bash
#SBATCH --job-name=HIFIASM
#SBATCH -e hifiasm_%J.err
#SBATCH -o hifiasm_%J.out
#SBATCH --time=48:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=60
#SBATCH --mem=480G
#SBATCH --partition=plant


#export HIFIASM=/cluster/home/scarey/packages/hifiasm-0.16.0
#export HIFIASM=/cluster/home/scarey/packages/hifiasm-0.19.5
export HIFIASM=/cluster/home/scarey/packages/hifiasm-0.19.6


$HIFIASM/hifiasm -o Humulus_lupuloides_MN-1421.default.asm -t 60 PacBio/m54262U_221029_043409.ccs.fastq.gz PacBio/m64040_221103_193910.ccs.fastq.gz PacBio/m64040_221105_045504.ccs.fastq.gz PacBio/m64040_221106_141244.ccs.fastq.gz --h1 ../Illumina/OmniC/KDUN_OmniC_NA_NA_TTCCAAGG_Humulus_lupulus_var_lupuloides_OmniC_-Humulus_lupulus_var_lupuloides_OmniC__I1273_L1_R1.fastq.gz --h2 ../Illumina/OmniC/KDUN_OmniC_NA_NA_TTCCAAGG_Humulus_lupulus_var_lupuloides_OmniC_-Humulus_lupulus_var_lupuloides_OmniC__I1273_L1_R2.fastq.gz 2> Humulus_lupuloides_MN-1421.default.asm.log


## to convert gfa to fasta use lines below
#awk '/^S/{print ">"$2"\n"$3}' Humulus_lupulus_21110M.trio.asm.hic.hap1.p_ctg.gfa | fold > Humulus_lupulus_21110M.trio.asm.hic.hap1.p_ctg.fasta

#awk '/^S/{print ">"$2"\n"$3}' Humulus_lupulus_21110M.trio.asm.hic.hap2.p_ctg.gfa | fold > Humulus_lupulus_21110M.trio.asm.hic.hap2.p_ctg.fasta

