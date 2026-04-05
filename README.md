# Bioinformatics Scripts

A collection of bioinformatics scripts for genome assembly, annotation, variant calling, pangenome analysis, and population genomics — primarily developed for plant genomics research (blueberry, tall fescue, and others).

Most scripts are written for **SLURM** job submission on an HPC cluster. Paths, modules, and resource parameters will need to be adjusted for your environment.

---

## Directory Structure

| Folder | Description |
|---|---|
| [`assembly/`](assembly/) | Genome assembly — Hifiasm, contig filtering, GFA, subsampling |
| [`alignment/`](alignment/) | Read alignment — BWA, Minimap2, pbmm2, SAMtools, pore-C |
| [`variant-calling/`](variant-calling/) | SNP/indel calling — FreeBayes, GATK, bcftools, VCF processing |
| [`sv-cnv/`](sv-cnv/) | Structural variants & CNVs — Sniffles, pbsv, sawfish, FreeC |
| [`annotation/`](annotation/) | Gene & repeat annotation — Braker, Helixer, EDTA, RepeatMasker, Liftoff |
| [`qc/`](qc/) | Quality control — FastQC, fastp, Meryl, Smudgeplot, BUSCO, Quast |
| [`scaffolding/`](scaffolding/) | Hi-C scaffolding — YAHS, RagTag, OmniC alignment |
| [`pangenome/`](pangenome/) | Pangenome analysis — GENESPACE, pankmer, panmap, Cactus, SyRI |
| [`phylogenetics/`](phylogenetics/) | Phylogenetics — IQ-TREE, ASTRAL, MAFFT |
| [`gwas-qtl/`](gwas-qtl/) | GWAS & QTL — GWASPoly, TASSEL, PLINK, Spartan, BLUEs extraction |
| [`utils/`](utils/) | Utilities — format converters, coverage tools, SRA download, loops |
| [`SarahCareyOmniCPipeline/`](SarahCareyOmniCPipeline/) | OmniC pipeline (Hi-C variant) |
| [`DEEPSPACE/`](DEEPSPACE/) | DEEPSPACE repeat annotation pipeline |

---

## Usage Notes

### SLURM submission
```bash
sbatch script_name.sh
```

### Typical resource tiers
- **Small jobs**: 20 cores, 50 GB RAM, 96 hours
- **Large assemblies**: 36 cores, 300 GB RAM, 400 hours

### Before running
1. Update hardcoded paths (input files, reference genomes, output directories)
2. Check `module load` lines match your cluster's module names
3. Activate the appropriate conda environment if required

---

## Key Workflows

### Genome Assembly (HiFi)
```
assembly/hifiasm.sbatch → assembly/ContigAssemblyFilter.sh → qc/compleasm.sh
```

### Hi-C Scaffolding
```
scaffolding/bwa_omnic.sbatch → scaffolding/yahs.sh → scaffolding/Post_YAHS.sh
```

### Variant Calling
```
alignment/BWA_Array.sh → variant-calling/FreeBayes_array.sh → variant-calling/bcftools_merge.sh
```

### Pangenome Analysis
```
pangenome/pankmer.sh → pangenome/Panmap2Vcf.sh → pangenome/filter_pangenome_vcf.sh
```

---

## Contact

Kendall Lee — [@Kendall-Lee](https://github.com/Kendall-Lee)
