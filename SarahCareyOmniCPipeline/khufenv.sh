#!/bin/bash
#SBATCH --job-name=@id_pipe
#SBATCH --partition=khufu
#SBATCH --ntasks=1
#SBATCH --mem=240gb
#SBATCH -c 12
#SBATCH --time=400:00:00
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
cd /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Downsample_Parents/downsampled_genomes
fqdir="/cluster/lab/clevenger/hwright/Sameer_Magic/"

#load khufu env
srun -c 4 --mem=40G -p interactive --pty /bin/bash
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source /cluster/projects/khufu/korani_projects/KhufuEnv/KhufuEnv.sh
#convert .fastq reads to .fasta (to use fasta2kmer)
#fastq2fasta @id.fq > @id_reads.fasta
#split into 1kb kmers (1kb length with 1kb window) via fasta2kmer
fastq2kmer $fqdir/@id.fastq 150 150 > @id_reads_150bpkmer.fastq
#fasta2fastq $fqdir/@id_reads_7kbkmer.fasta > @id_7kbmer.fastq | gzip @id_7kbmer.fastq


for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Downsample_Parents/kmerized_genomes/*fast | sed "s:_reads_7kbkmer.fasta::g; s:.*/::g"); do cat ./fasta2fastq.sh | sed "s:@id:$i:g" > fasta2fastq_"$i".sh; done


for i in $(ls /cluster/lab/clevenger/hwright/Sameer_Magic/*HIFI.fastq| sed "s:.fastq::g; s:.*/::g"); do cat ./kmer.sh | sed "s:@id:$i:g" > kmer_"$i".sh; done
