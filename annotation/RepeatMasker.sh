#!/bin/bash
#SBATCH -J RepeatMasker
#SBATCH --time=96:00:00
#SBATCH -c 16
#SBATCH -N 1
#SBATCH -p highmem
#SBATCH -o "stds/stdout_repeats"
#SBATCH -e "stds/stderr_repeats"
#SBATCH --mem="400G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL

ml cluster/repeatmodeler/2.0.5
ml cluster/repeatmasker/4.1.7

CONTAINER="/cluster/software/repeatmodeler-2.0.5/dfam-tetools-1.89.1.sif"
GENOME="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_Full.fa"
DB="Suziblue"

#singularity exec --bind /cluster:/cluster --bind /scratch:/scratch $CONTAINER BuildDatabase -name ${DB} -engine ncbi ${GENOME}

singularity exec --bind /cluster:/cluster --bind /scratch:/scratch $CONTAINER RepeatModeler -database ${DB} -pa 72 -LTRStruct

singularity exec --bind /cluster:/cluster --bind /scratch:/scratch $CONTAINER RepeatMasker -pa 72 -lib ${DB}-families.fa -xsmall ${GENOME}

mkdir trf
cd trf
ln -s ../genome.fa.masked genome.fa
splitMfasta.pl --minsize=25000000 genome.fa
ls genome.split.*.fa | parallel 'trf {} 2 7 7 80 10 50 500 -d -m -h &> {}.log'
ls genome.split.*.fa.2.7.7.80.10.50.500.dat | parallel 'parseTrfOutput.py {} --minCopies 1 \
    --statistics {}.STATS > {}.raw.gff 2> {}.parsedLog'
ls genome.split.*.fa.2.7.7.80.10.50.500.dat.raw.gff | parallel 'sort -k1,1 -k4,4n -k5,5n {} \
    > {}.sorted 2> {}.sortLog'
FILES=genome.split.*.fa.2.7.7.80.10.50.500.dat.raw.gff.sorted
for f in $FILES do
    bedtools merge -i $f | awk 'BEGIN{OFS="\t"} {print $1,"trf","repeat",$2+1,$3,".",".",".","."}' \
        > $f.merged.gff 2> $f.bedtools_merge.log
done
ls genome.split.*.fa | parallel 'bedtools maskfasta -fi {} -bed \
    {}.2.7.7.80.10.50.500.dat.raw.gff.sorted.merged.gff -fo {}.combined.masked -soft &> {}.bedools_mask.log'
cat genome.split.*.fa.combined.masked > genome.fa.combined.masked
