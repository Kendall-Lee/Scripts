#!/bin/bash
#SBATCH -J seqkit_W.2024.SP.SL.D3.F1.14_R2
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="190G"


seqkit fx2tab -q W.2024.SP.SL.D3.F1.14_R2.fq.gz | awk -F'\t' '{total+=length($2); aboveQ20+=gsub(/[\!\\"#$%&'\''()*+,-]/,"",$3)} END {print (aboveQ20/total)*100"%"}' > W.2024.SP.SL.D3.F1.14_R2.out



reformat.sh in=W.2024.SP.SL.D3.F1.14_R2.fq.gz bhist=W.2024.SP.SL.D3.F1.14_R2_quality_hist.txt



for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short/*fq.gz | sed "s:_R[12].fq.gz::g"); do cat ./qc.sh | sed "s:@id:$i:g" > qc_"$i".sh; done
