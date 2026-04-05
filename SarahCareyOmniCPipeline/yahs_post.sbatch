#!/bin/bash
#SBATCH --job-name=YAHS
#SBATCH -e yahs_%J.err
#SBATCH -o yahs_%J.out
#SBATCH --time=12:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --partition=plant


#source activate yahs

/cluster/lab/harkess/bin/yahs-1.1/juicer post -o Humulus_lupuloides_MN-1421.default_hap1_JBAT Humulus_lupuloides_MN-1421.default_hap1_JBAT.review.assembly Humulus_lupuloides_MN-1421.default_hap1_JBAT.liftover.agp Humulus_lupuloides_MN-1421.default.hic.hap1.p_ctg.racon_plusY.50000.fa

/cluster/lab/harkess/bin/yahs-1.1/juicer post -o Humulus_lupuloides_MN-1421.default_hap2_JBAT Humulus_lupuloides_MN-1421.default_hap2_JBAT.review.assembly Humulus_lupuloides_MN-1421.default_hap2_JBAT.liftover.agp Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa

