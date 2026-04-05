#!/bin/bash
#SBATCH -e Cov_%j.err
#SBATCH -o Cov_%j.out
#SBATCH --job-name=Coverage_Analysis
#SBATCH --time-min=120:00:00
#SBATCH --ntasks=20
#SBATCH --mem=160G
#SBATCH --partition=plant
#SBATCH --nodes=1


module load cluster/bedtools/2.28.0
module load cluster/bwa/0.7.17
ml cluster/minimap2/2.26
ml samtools/1.19.2-gcc-13.1.0

#1 Installing Minimap2 NOTE: Not needed if alreay have minimap
# conda create -n Minimap
# conda activate Minimap
# conda install bioconda::minimap2
id="@id"
ref="//cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
fqdir="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/LRLP_blueberry/New_fastqs"
query="$fqdir"/$id".fastq.gz"

# #2 Making the bam file
minimap2 -ax asm5 $ref $query | samtools view -S -h -b -F 2316 > $id.Suzibluehap1.bam
# #
# # #3 Indexing the .fasta file
samtools faidx $ref
cut -f 1,2 $ref.fai > SuziblueHap1.Chr.sizes
#
# #4 Making .bed file we will use to create for our sliding windows
bedtools makewindows -g  TRv2.Chr.sizes -w 1000000 -s 100000 >  $id.Windows.bed

#5 Sorting the .bam file
samtools sort $id.Suzibluehap1.bam -o $id.Suzibluehap1.sorted.bam

#6 Generating the depth.txt file for Genome
bedtools coverage -sorted -b $id.Suzibluehap1.sorted.bam -a $id.Windows.bed -mean > $id.Windows.coverage.txt

#############

for i in $(ls $fqdir/*.fastq.gz | sed "s:.*/::; s:.fastq.gz::g"); do cat ./coverage.sh | sed "s:@id:$i:g" > coverage"$i".sh; done


#####################################
#########   as an array   #########
######################################
#!/bin/bash
#SBATCH -e Cov_%A_%a.err
#SBATCH -o Cov_%A_%a.out
#SBATCH --job-name=Coverage_Analysis
#SBATCH --time=120:00:00
#SBATCH --ntasks=20
#SBATCH --mem=160G
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --array=1-96   # <-- adjust range based on number of samples

# Load required modules
module load cluster/bedtools/2.28.0
module load cluster/bwa/0.7.17
module load cluster/minimap2/2.26
module load samtools/1.19.2-gcc-13.1.0

# =================================================================
# Get sample ID from samples.txt based on array task ID
# =================================================================
SAMPLE_LIST="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/PANGENOME/Short_fastqs/samples.txt"
id=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $SAMPLE_LIST)

# Paths
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
fqdir="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/PANGENOME/Short_fastqs"
R1="${fqdir}/${id}_R1.fq.gz"
R2="${fqdir}/${id}_R2.fq.gz"

# Output files
bam="${id}.Suzibluehap1.bam"
sortedbam="${id}.Suzibluehap1.sorted.bam"
bedfile="${id}.Windows.bed"
covfile="${id}.Windows.coverage.txt"

# =================================================================
# Step 1: Align reads and create a BAM file
# # =================================================================
minimap2 -ax asm5 $ref $query | samtools view -S -h -b -F 2316 > $bam
#
# # =================================================================
# # Step 2: Index FASTA if not already done
# # =================================================================
# if [ ! -f "${ref}.fai" ]; then
#     samtools faidx $ref
#     cut -f 1,2 ${ref}.fai > SuziblueHap1.Chr.sizes
# fi

# =================================================================
# Step 3: Create sliding windows BED file (1 Mb windows, 100 kb step)
# =================================================================
bedtools makewindows -g SuziblueHap1.Chr.sizes -w 1000000 -s 100000 > $bedfile

# =================================================================
# Step 4: Sort BAM file
# =================================================================
samtools sort $bam -o $sortedbam

# =================================================================
# Step 5: Compute coverage
# =================================================================
bedtools coverage -sorted -b $sortedbam -a $bedfile -mean > $covfile



###############################################################################
#####################Short read array###########################################
################################################################################


#!/bin/bash
#SBATCH -e Cov_%A_%a.err
#SBATCH -o Cov_%A_%a.out
#SBATCH --job-name=Coverage_Analysis
#SBATCH --time=120:00:00
#SBATCH --ntasks=20
#SBATCH --mem=160G
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --array=1-96       # adjust to the number of samples

# -------------------- Modules --------------------
module load cluster/bwa/0.7.17
module load cluster/samtools/1.19.2-gcc-13.1.0
module load cluster/bedtools/2.28.0

# -------------------- Inputs ---------------------
SAMPLE_LIST="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/PANGENOME/Short_fastqs/samples.txt"
id=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
fqdir="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/PANGENOME/Short_fastqs"
R1="${fqdir}/${id}_R1.fq.gz"
R2="${fqdir}/${id}_R2.fq.gz"

# -------------------- Outputs --------------------
bam="${id}.Suzibluehap1.bam"
sortedbam="${id}.Suzibluehap1.sorted.bam"
bedfile="${id}.Windows.bed"
covfile="${id}.Windows.coverage.txt"
sizes="SuziblueHap1.Chr.sizes"

# =================================================
# 1.  Index the reference if needed
# =================================================
if [ ! -f "${ref}.bwt" ]; then
    echo "Indexing reference with BWA ..."
    bwa index "$ref"
fi
if [ ! -f "${ref}.fai" ]; then
    echo "Creating FASTA index and chromosome sizes ..."
    samtools faidx "$ref"
    cut -f 1,2 "${ref}.fai" > "$sizes"
fi

# =================================================
# 2.  Align paired‑end reads with BWA‑MEM
# =================================================
echo "Aligning ${id} ..."
bwa mem -t "$SLURM_NTASKS" "$ref" "$R1" "$R2" \
    | samtools view -bS -F 2316 -o "$bam" -

# =================================================
# 3.  Create sliding‑window BED file (1 Mb windows, 100 kb step)
# =================================================
bedtools makewindows -g "$sizes" -w 1000000 -s 100000 > "$bedfile"

# =================================================
# 4.  Sort BAM
# =================================================
samtools sort -@ "$SLURM_NTASKS" -o "$sortedbam" "$bam"

# =================================================
# 5.  Compute average coverage per window
# =================================================
bedtools coverage -sorted -a "$bedfile" -b "$sortedbam" -mean > "$covfile"

echo "Done for sample ${id}"
