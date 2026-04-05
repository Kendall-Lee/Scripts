#!/bin/bash
#SBATCH -J fastqc
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_fastq"
#SBATCH -e "stds/stderr_fastqc"
#SBATCH --mem="200G"

id="@id"
outdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short/fastqc_out"

fastqc -o $outdir "$id"_R1.fq.gz "$id"_R2.fq.gz



for i in $(ls ./*gz | sed "s:_R[12].fq.gz::g; s:.*/::g"); do cat ./fastqc.sh | sed "s:@id:$i:g" > fastqc_"$i".sh; done
