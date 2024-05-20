#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=variant_table
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=0-18:00:00
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
echo "Variant Table SNP"
gatk --java-options "-Xmx10g" \
VariantsToTable \
-R ${GEN_DIR}/AnoGra1.1.fa \
-V ${INDIR}/${SAMPLE}.genotype.g.vcf.gz \
-F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
-O ${OUT_SNP}/${SAMPLE}_snps.table

echo ""
echo "Variant Table Indel"
gatk --java-options "-Xmx10g" \
VariantsToTable \
-R ${GEN_DIR}/AnoGra1.1.fa \
-V ${INDIR}/${SAMPLE}.genotype.g.vcf.gz \
-F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
-O ${OUT_INDEL}/${SAMPLE}_indels.table

echo ""
echo "done"
