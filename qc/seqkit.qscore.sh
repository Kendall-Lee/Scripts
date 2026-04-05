#!/bin/bash
#SBATCH --job-name=seqkit
#SBATCH -e seqkit_%J.err
#SBATCH -o seqkit_%J.out
#SBATCH --time=12:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=12
#SBATCH --mem=60G
#SBATCH --partition=plant


seqkit fq2fa B791.HiFi.fastq.gz -o B791.HiFi.fasta.gz



#seqkit fx2tab -q your_reads.fastq.gz | awk -F'\t' '{total+=length($2); aboveQ20+=gsub(/[!"#$%&'()*+,-]/,"",$3)} END {print (aboveQ20/total)*100"%"}'
