#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=genotype
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
#SBATCH --mem=100G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=5-00:00:00
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
INDIR="/projects/f_geneva_1/alyssa/sagrei/combine_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
OUTDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"

echo "${COHORT}"

echo ""
echo "genotype gVCFs"
gatk --java-options "-Xmx100g" GenotypeGVCFs \
-R ${GEN_DIR}/AnoSag2.1.fa \
-V ${INDIR}/${COHORT}_cohort.g.vcf.gz \
-O ${OUTDIR}/${COHORT}_cohort.genotype.g.vcf.gz


echo ""
echo "done"
