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
ml cluster/java/17.0.9
module load cluster/samtools/1.10
#
# samtools faidx B791_1errOmniCploidy.asm.hic.p_ctg.fa
#
# /cluster/lab/harkess/bin/yahs-1.1/yahs B791_1errOmniCploidy.asm.hic.p_ctg.fa B791_Primary.sorted.bam -o B791_Primary
#
# /cluster/lab/harkess/bin/yahs-1.1/juicer pre -a -o B791_Primary_JBATB791_Primary.bin B791_Primary_scaffolds_final.agp B791_1errOmniCploidy.asm.hic.p_ctg.fa.fai > B791_Primary_JBAT.log 2>&1

java -jar -Xmx150G /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre B791_Primary_JBAT.txt B791_Primary_JBAT.hic <(echo "assembly 1941067377")



#samtools faidx Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa

#/cluster/lab/harkess/bin/yahs-1.1/yahs Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY_OmniC.bam -o Humulus_lupuloides_MN-1421.default_hap2

#/cluster/lab/harkess/bin/yahs-1.1/juicer pre -a -o Humulus_lupuloides_MN-1421.default_hap2_JBAT Humulus_lupuloides_MN-1421.default_hap2.bin Humulus_lupuloides_MN-1421.default_hap2_scaffolds_final.agp Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa.fai > Humulus_lupuloides_MN-1421.default_hap2_JBAT.log 2>&1

java -jar -Xmx150G /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre Humulus_lupuloides_MN-1421.default_hap2_JBAT.txt Humulus_lupuloides_MN-1421.default_hap2_JBAT.hic <(echo "assembly 1336934255")

/cluster/lab/harkess/bin/yahs-1.1/juicer pre -a -o CB7_asm_hic_hap1_test_JBAT CB7_asm_hic_hap1_test.bin CB7_asm_hic_hap1_test_scaffolds_final.agp CB7.asm.hic.hap1.p_ctg.fa.fai > CB7_asm_hic_hap1_test_JBAT.log 2>&1
