#!/bin/bash
#SBATCH -J subsample_@id
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 2
#SBATCH -p khufu
#SBATCH -o stdout_sub
#SBATCH -e stderr_sub
#SBATCH --mem="200G"

43506642589
# For subsampling
# Assign the variable actualLength to a command that removes the headers from the reference fasta file and then counts all the characters to get the length
#actualLength=$(cat /cluster/home/klee/PacBio_project/ref.fa | grep -v ">" | awk '{X=X+length($0)} END {print X}')
# Assign fq to the file name
id=" Yorkfinal150bpkmer"
# Calculate the target length for 0.9x coverage
#targetLength=$(echo "scale=0; $actualLength * 1" | bc)
targetLength=2672191898
# Count how many lines are needed to reach the target genome length
len=$(zcat $id.fastq.gz | awk '{if (NR%4==2){X+=length($0); if (X>=Y){print NR+2; exit}}}' Y=$targetLength)

# Extract the required lines
zcat $id.fq.gz | head -n "$len" | gzip > $id.1x.Pan.fastq.gz


for i in $(ls ./*fastq.gz| sed 's:.fastq.gz::g' | sed 's:.*/::g'); do cat ./downsample.sh | sed "s:@id:$i:g" > downsample_"$i".sh; done


for i in $(ls /cluster/lab/clevenger/hwright/Sameer_Magic/*HIFI.fastq| sed 's:.fastq.gz::g' | sed 's:.*/::g'); do cat ./downsample.sh | sed "s:@id:$i:g" > downsample_"$i".sh; done
for i in $(ls /cluster/lab/clevenger/hwright/Sameer_Magic/*HIFI.fastq; do cp $i ./; done

### for short read data ######

#!/bin/bash
#SBATCH -J subsample
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 2
#SBATCH -p khufu
#SBATCH -o stdout_sub
#SBATCH -e stderr_sub
#SBATCH --mem="200G"

# For subsampling paired-end short-read data
# Assign the variable actualLength to a command that removes the headers from the reference fasta file and then counts all the characters to get the length
actualLength=$(cat /cluster/home/klee/PacBio_project/ref.fa | grep -v ">" | awk '{X=X+length($0)} END {print X}')

# File names for paired-end reads
fq1="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Downsample_Parents/downsampled_genomes/SR/SR_files/MG0016.IAC322.3_R1.fq.gz"
fq2="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Downsample_Parents/downsampled_genomes/SR/SR_files/MG0016.IAC322.3_R2.fq.gz"

# Calculate the target length for desired coverage (e.g., 1x coverage)
targetLength=$(echo "scale=0; $actualLength * 1" | bc)

# Count how many lines are needed to reach the target genome length (based on read lengths in R1)
len=$(zcat $fq1 | awk '{if (NR%4==2){print length($0)}}' | awk -v Y=$actualLength '{X=$0+X;if (X>=Y){print NR*4}}')

# Subsample both R1 and R2 using the same line count
zcat $fq1 | head -"$len" | gzip > ${fq1%.fastq.gz}.subsample.fastq.gz
zcat $fq2 | head -"$len" | gzip > ${fq2%.fastq.gz}.subsample.fastq.gz
