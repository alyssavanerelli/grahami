#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=vcftools_table
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=2-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load VCFtools/vcftools-v0.1.16-13-yc759

echo ""
echo "load variables"
#SAMPLE=$1
SAMPLE='DTG-SG-149'
INDIR="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf"
BASE_DIR='/projects/f_geneva_1/alyssa/grahami/gatk'
OUT_SNP="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/snps"
OUT_INDEL="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/indels"
OUT_INVARIANT="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/invariant"
SNPS=${OUT_SNP}/${SAMPLE}_snps_filtered_depth_passed.vcf
OUTFILE_SNP=${OUT_SNP}/${SAMPLE}_snps_vcftools
INVAR=${OUT_INVARIANT}/${SAMPLE}_invariants_filtered_depth_passed.vcf
OUTFILE_INV=${OUT_INVARIANT}/${SAMPLE}_invariants_vcftools



echo ""
echo "run vcftools snps"
vcftools --vcf ${SNPS} --freq2 --out $OUTFILE_SNP --max-alleles 2           # Calculate allele frequency for each variant. --freq2 just outputs the frequencies without information about the alleles. Max-alleles 2 excludes sites that have more than two alleles

vcftools --vcf ${SNPS} --depth --out $OUTFILE_SNP                           # Calculate mean depth of coverage per individual

vcftools --vcf ${SNPS} --site-mean-depth --out $OUTFILE_SNP                 # Calculate mean depth per site

vcftools --vcf ${SNPS} --site-quality --out $OUTFILE_SNP                    # Calculate site quality score for each site

vcftools --vcf ${SNPS} --missing-indv --out $OUTFILE_SNP                    # Calculate proportion of missing data per sample

vcftools --vcf ${SNPS} --missing-site --out $OUTFILE_SNP                    # Calculate missing data per site

vcftools --vcf ${SNPS} --het --out $OUTFILE_SNP                             # Calculate heterozygosity and inbreeding coefficient per individual

echo ""
echo "done"
