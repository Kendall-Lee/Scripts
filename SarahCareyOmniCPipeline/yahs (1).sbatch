#!/bin/bash
#SBATCH --job-name=YAHS
#SBATCH -e yahs_%J.err
#SBATCH -o yahs_%J.out
#SBATCH --time=48:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=25
#SBATCH --mem=150G
#SBATCH --partition=plant


#source activate yahs

module load cluster/samtools/1.10

samtools faidx Humulus_lupuloides_MN-1421.default.hic.hap1.p_ctg.racon_plusY.50000.fa

/cluster/lab/harkess/bin/yahs-1.1/yahs Humulus_lupuloides_MN-1421.default.hic.hap1.p_ctg.racon_plusY.50000.fa Humulus_lupuloides_MN-1421.default.hic.hap1.p_ctg.racon_plusY_OmniC.bam -o Humulus_lupuloides_MN-1421.default_hap1

/cluster/lab/harkess/bin/yahs-1.1/juicer pre -a -o Humulus_lupuloides_MN-1421.default_hap1_JBAT Humulus_lupuloides_MN-1421.default_hap1.bin Humulus_lupuloides_MN-1421.default_hap1_scaffolds_final.agp Humulus_lupuloides_MN-1421.default.hic.hap1.p_ctg.racon_plusY.50000.fa.fai > Humulus_lupuloides_MN-1421.default_hap1_JBAT.log 2>&1

#java -jar -Xmx150G /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre Humulus_lupuloides_MN-1421.default_hap1_JBAT.txt Humulus_lupuloides_MN-1421.default_hap1_JBAT.hic <(echo "assembly 1325771365")




#samtools faidx Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa

#/cluster/lab/harkess/bin/yahs-1.1/yahs Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY_OmniC.bam -o Humulus_lupuloides_MN-1421.default_hap2

#/cluster/lab/harkess/bin/yahs-1.1/juicer pre -a -o Humulus_lupuloides_MN-1421.default_hap2_JBAT Humulus_lupuloides_MN-1421.default_hap2.bin Humulus_lupuloides_MN-1421.default_hap2_scaffolds_final.agp Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa.fai > Humulus_lupuloides_MN-1421.default_hap2_JBAT.log 2>&1

#java -jar -Xmx150G /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre Humulus_lupuloides_MN-1421.default_hap2_JBAT.txt Humulus_lupuloides_MN-1421.default_hap2_JBAT.hic <(echo "assembly 1336934255")

/cluster/lab/harkess/bin/yahs-1.1/juicer pre -a -o B080_OmniC_utg_JBAT B080_OmniC_utg.bin B080_OmniC_utg_scaffolds_final.agp /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Primary_hifiasm/B080_RE.hifiasm.bp.p_utg.fa.fai
