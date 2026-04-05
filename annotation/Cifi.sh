#!/bin/bash
#SBATCH -J minimap_@id
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"
ml samtools/1.19.2-gcc-13.1.0

module load cluster/minimap2/2.26
#Cifi pipeline

#use long read mapper to generate a bam file

#minimap2 -t 12 -ax map-hifi /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.chrOnly.fasta m84238_251104_205516_s1.hifi_reads.bc2033.fastq \
  #| samtools sort -o B080_W85_cifi_aln.sorted.bam
samtools index m84238_251104_205516_s1.hifi_reads.bc2033.bam


#identify ligation junction motifs characteristic of the Omni‑C linker.
#Split each long read at these motifs to create virtual pairs (similar to R1/R2 pairs in Hi‑C data).
#
# Hifiasm assembly.fa
#            ↓
# minimap2/pbmm2 map-hifi (CiFi SE reads)
#            ↓
# cifi_aln.sorted.bam
#            ↓
# Detect ligation junctions → generate pairs
#            ↓
# YAHS scaffolding with pairs
#            ↓
# Juicer .hic → Juicebox for inspection

#!/bin/bash
#SBATCH -J minimap_B080
#SBATCH --time=96:00:00
#SBATCH -c 20                     # matches --threads below or keep consistent
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem=300G
#SBATCH -o stds/stdout_%x_%j.txt
#SBATCH -e stds/stderr_%x_%j.txt
# Load required modules / activate conda environment
module load cluster/singularity/3.11.0

# Make sure conda commands can be used inside the batch job
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/CiFi_Nextflow_env

# Optional: keep Nextflow Singularity cache in a persistent location
export NXF_SINGULARITY_CACHEDIR=/cluster/lab/clevenger/KLee/singularity

# Bind required host paths so the container can see them
export NXF_SINGULARITY_BINDPATH="/cluster/home/klee,/cluster/lab/clevenger/KLee"

# Run the workflow
nextflow run /cluster/lab/clevenger/KLee/CiFi/wf-pore-c \
    -work-dir ./workflow_noOmniC_B080 \
    -profile singularity \
    --bam 'm84238_251104_205516_s1.hifi_reads.bc2033.bam' \
    --ref '/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_noOmniC.asm.bp.p_ctg.fa' \
    --cutter 'OmniC_Bridge' \
    --out_dir './RESULTS_noOmniC_B080' \
    --chunk_size 300000 \
    --threads 20 \
    --minimap2_settings '-x map-hifi' \
    --paired_end \
    --sample 'B080' \
    -with-trace \
    -resume



########check paired end bams
#!/bin/bash
#SBATCH -J monomer_stats
#SBATCH --time=96:00:00
#SBATCH -c 20                     # matches --threads below or keep consistent
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem=300G
#SBATCH -o stds/stdout_%x_%j.txt
#SBATCH -e stds/stderr_%x_%j.txt
# Load required modules / activate conda environment

module load samtools/1.19.2-gcc-13.1.0

# 2. estimate monomer stats
samtools view B080.sorted.mq20.bam| \
  awk -F':' '{c[$1]++} END {for (i in c){total+=c[i]; n++}
  print "Concatemers:",n,"Monomers:",total,"Mean:",total/n}' > monomer.stats


#monomers per concatemer
  samtools view B080.sorted.mq20.bam | awk -F':' '{c[$1]++} END {
    total_pairs=0; n=0;
    for (i in c){n++; total_pairs += c[i]*(c[i]-1)/2}
    print "Reads:", n, "Total_expected_pairs:", total_pairs,
          "Mean_pairs_per_read:", total_pairs/n
  }'> monomerspercat.txt


# 3. monomer length
samtools view B080_out.ns.bam | awk '{print length($10)}' > monomer_lengths.txt

# 4. confirm tag presence
# MI → concatemer ID (group key for all segments from the same read).
# Xc → detailed monomer metadata (start/end/index info).
# Xw → annotation walk/orientation string (added later).
samtools view B080.ns.bam | head -20 | grep -E "MI:|Xc:|Xw:"

#!/bin/bash
#SBATCH -J bamfilter
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem=300G
#SBATCH -o stds/stdout_%x_%j.txt
#SBATCH -e stds/stderr_%x_%j.txt
# Load required modules / activate conda environment


# Make sure conda commands can be used inside the batch job
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/bamfilter

/cluster/home/klee/filter_bam B080.ns.bam B080.sorted.mq0.bam 0 8




#!/bin/bash
#SBATCH --job-name=YAHS_B080.sh
#SBATCH -e YAHSF4_B080_utg%J.err
#SBATCH -o YAHSF4_B080_utg%J.out
#SBATCH --time=200:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=30
#SBATCH --mem=300Gb
#SBATCH --partition=highmem


module load samtools/1.19.2-gcc-13.1.0
module load cluster/java/17.0.9

 /cluster/home/klee/yahs/yahs /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_noOmniC.asm.bp.p_ctg.fa /cluster/lab/clevenger/KLee/CiFi/RESULTS_noOmniC_B080/paired_end/stds/B080.sorted.mq0.bam -o B080.haps.CiFi.mq0
# # #
 /cluster/home/klee/yahs/juicer pre -a -o B080.haps.CiFi.mq0_JBAT B080.haps.CiFi.mq0.bin B080.haps.CiFi.mq0_scaffolds_final.agp /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_noOmniC.asm.bp.p_ctg.fa.fai > B080.haps.CiFi.mq0_JBAT.log 2>&1

# have to check the *.log file for the size to use for assembly before running this line

java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre B080.haps.CiFi.mq0_JBAT.txt B080.haps.CiFi.mq0_JBAT.hic <(echo "assembly 1497975525")
