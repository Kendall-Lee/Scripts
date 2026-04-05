#!/bin/bash
#SBATCH --job-name=YAHS_post
#SBATCH -e B791_hap1_YAHS_post.%J.err
#SBATCH -o B791_hap1_YAHS_post.%J.out
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=200G
#SBATCH --partition=khufu

#/cluster/home/klee/yahs/juicer post -o iteration2Hap1 B791_hap1_JBAT.review4.assembly B791_hap1_JBAT.liftover.agp B791_Hap1_filtered.fasta


assembly="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_noOmniC.asm.bp.p_ctg.fa"

/cluster/home/klee/yahs/juicer post -o B080_R1 B080.haps.CiFi.mq0_JBAT.review.autosave.assembly B080.haps.CiFi.mq0_JBAT.liftover.agp $assembly
