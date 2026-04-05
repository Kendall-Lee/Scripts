#!/bin/bash
#SBATCH -J snpEff
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_snpEff"
#SBATCH -e "stds/stderr_snpEff"
#SBATCH --mem="100G"


ml cluster/java/17.0.9

id="SRLP_Smiss0.99_TRv2.named.svs"
vcf_dir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/New_Pan_Walid"
input="$vcf_dir"/$id".vcf"
output="$id".snpEff.vcf

java -jar snpEff.jar peanut $input > $output


### make sbatch ######
for i in $( ls  /cluster/lab/clevenger/KLee/Wiregrass_LRLP/SV_files/VCF_files/ | sed "s:_.*::g" | sed "s:.pbmm.sorted.vcf::g"); do cat ./snpEff_template.sh| sed "s:@id:$i:g" > snpEff_"$i".sh; done
java -jar snpEff.jar peanut W.2024.SP.RB.D3.F1.hapmap.header.vcf > W.2024.SP.RB.D3.F1.hapmap.header.snpEff.vcf
