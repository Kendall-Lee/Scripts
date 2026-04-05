#!/bin/bash
#SBATCH -J Cifi
#SBATCH --time=96:00:00
#SBATCH -c 20                     # matches --threads below or keep consistent
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH --mem=300G
#SBATCH -o stds/stdout_%x_%j.txt
#SBATCH -e stds/stderr_%x_%j.txt


#script by Kendall Lee, November 2025
#adapted from Dennis Lab CiFi workflow with the help of Sean McGinty

module load cluster/singularity/3.11.0

# Make sure conda commands can be used inside the batch job
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/CiFi_Nextflow_env

# Optional: keep Nextflow Singularity cache in a persistent location
export NXF_SINGULARITY_CACHEDIR=/cluster/lab/clevenger/KLee/singularity

# Bind required host paths so the container can see them
export NXF_SINGULARITY_BINDPATH="/cluster/home/klee,/cluster/lab/clevenger/KLee"
#don't ever mess with the input files ever again!!!!! I finally got all iterations of adapter sequence cutting and digesting. If you do make backups
#follow install instructions via https://github.com/mydennislab/CiFi

#Create a custom conda env containing pore-c-py. You can run this to create: mamba env create -f Arima_Hive_pore_c_py_env.yml -n custom_cutter_CiFi_env
#Upon creation of this new environment you should have a file, digest.py located here: /PATH/TO/miniconda3/ENV/custom_cutter_CiFi_env/lib/python3.10/site-packages/pore_c_py. Replace folder pore-c_py with the one the folder i have provided. I have edited many files in it
#Make sure to use the wf_pore_c folder I made
#follow the script below and it should all run

# Run the workflow
nextflow run /cluster/lab/clevenger/KLee/CiFi/wf-pore-c \
    -work-dir ./workflow_HapsOmniC_B080 \
    -profile singularity \
    --bam 'm84238_251104_205516_s1.hifi_reads.bc2033.bam' \
    --ref '/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_Haps.sorted_scaffolds_final.fa' \
    --cutter 'OmniC_Bridge' \
    --out_dir './RESULTS_HapsOmniC_B080' \
    --chunk_size 300000 \
    --threads 20 \
    --minimap2_settings '-x map-hifi' \
    --paired_end \
    --sample 'B080' \
    -with-trace \
    -resume

#############################################
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

#use the ns.bam from the folder "paired end"

# Make sure conda commands can be used inside the batch job
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/bamfilter

/cluster/home/klee/filter_bam B080.ns.bam B080.SR.sorted.mq0.bam 0 8 # for polyploid do mq=0 bc or else multimaps will be filtered

#########################################################################
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

# samtools faidx /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_Haps.sorted_scaffolds_final.fa
# /cluster/home/klee/yahs/yahs /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_Haps.sorted_scaffolds_final.fa /cluster/lab/clevenger/KLee/CiFi/RESULTS_HapsOmniC_B080/paired_end/B080.SR.HAPS.sorted.mq0.bam -o B080.haps.CiFi.mq0.SR.HAPS
# # # #
# /cluster/home/klee/yahs/juicer pre -a -o B080.haps.CiFi.mq0.SR.HAPS_JBAT B080.haps.CiFi.mq0.SR.HAPS.bin B080.haps.CiFi.mq0.SR.HAPS_scaffolds_final.agp /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_Haps.sorted_scaffolds_final.fa.fai > B080.haps.CiFi.mq0.SR.HAPS_JBAT.log 2>&1

# have to check the *.log file for the size to use for assembly before running this line

java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre B080.haps.CiFi.mq0.SR.HAPS_JBAT.txt B080.haps.CiFi.mq0.SR.HAPS_JBAT.hic <(echo "assembly 2115597017")
