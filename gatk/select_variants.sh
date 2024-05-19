#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=variants
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=20G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load GATK/4.2.2.0-yc759


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

echo ""
echo "select SNPs"
gatk SelectVariants \
-R ${GEN_DIR}/AnoGra1.1.fa \
-V ${INDIR}/${SAMPLE}.genotype.g.vcf.gz \
--select-type-to-include SNP \
-O ${OUT_SNP}/${SAMPLE}_snps.vcf.gz


echo ""
echo "select indels"
gatk SelectVariants \
-R ${GEN_DIR}/AnoGra1.1.fa \
-V ${INDIR}/${SAMPLE}.genotype.g.vcf.gz \
--select-type-to-include INDEL \
-O ${OUT_INDEL}/${SAMPLE}_indels.vcf.gz

echo ""
echo "select invariant sites"
gatk SelectVariants \
-R ${GEN_DIR}/AnoGra1.1.fa \
-V ${INDIR}/${SAMPLE}.genotype.g.vcf.gz \
--select-type-to-include NO_VARIATION \
-O ${OUT_INVARIANT}/${SAMPLE}_invariants.vcf.gz


echo ""
echo "done"
