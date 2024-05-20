#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --constraint=oarc
#SBATCH --job-name=variant_table
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
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
module load GATK/4.2.2.0-yc759


echo ""
echo "load variables"
COHORT=$1
INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"


echo ""
echo "Variant Table SNP"
gatk --java-options "-Xmx10g" \
VariantsToTable \
-R ${GEN_DIR}/AnoSag2.1.fa \
-V ${OUT_SNP}/${COHORT}_snps.vcf.gz \
-F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
-O ${OUT_SNP}/${COHORT}_snps.table

echo ""
echo "Variant Table Indel"
gatk --java-options "-Xmx10g" \
VariantsToTable \
-R ${GEN_DIR}/AnoSag2.1.fa \
-V ${OUT_INDEL}/${COHORT}_indels.vcf.gz \
-F CHROM -F POS -F QUAL -F QD -F DP -F MQ -F MQRankSum -F FS -F ReadPosRankSum -F SOR \
-O ${OUT_INDEL}/${COHORT}_indels.table

echo ""
echo "done"
