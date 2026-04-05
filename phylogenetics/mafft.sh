#!/bin/bash
#SBATCH --job-name=mafft
#SBATCH --partition=batch
#SBATCH --mem=50gb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=10:00:00
#SBATCH --output=mafft.out
#SBATCH --error=mafft.error

## load mafft
ml MAFFT/7.505-GCC-11.3.0-with-extensions
## make multiple sequence alignment using mafft's accuracy-oriented method (*L-INS-i)
mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 tubB_genes  > tubB_genes.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 transcriptional_activator_leucine_zipper.fa  > transcriptional_activator_leucine_zipper.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 fatty_acid_synthase_beta_subunit_dehydratase.fa  > fatty_acid_synthase_beta_subunit_dehydratase.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 Ribosomal_protein_L19.fa  > Ribosomal_protein_L19.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 DNA_polymerase_epsilon_catalytic_subunit.fa  > DNA_polymerase_epsilon_catalytic_subunit.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 Armadillo_type_fold_protein.fa  > Armadillo_type_fold_protein.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 Kinesin_genes.fa  > Kinesin_genes.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 FMP27_SW_domain_genes.fa  > FMP27_SW_domain_genes.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 Midasin_genes.fa  > Midasin_genes.aln

mafft --adjustdirectionaccurately --thread 8 --nuc --localpair --maxiterate 1000 Glutamate_synthesis.fa  > Glutamate_synthesis.aln
