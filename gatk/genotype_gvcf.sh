#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=genotype
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=100G
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
INDIR="/projects/f_geneva_1/alyssa/grahami/gatk/haplotype_caller"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf"
BASE_DIR='/projects/f_geneva_1/alyssa/grahami/gatk'


echo ""
echo "genotype gVCFs"
gatk --java-options "-Xmx100g" GenotypeGVCFs \
-R ${GEN_DIR}/AnoGra1.1.fa \
-V ${INDIR}/${SAMPLE}.g.vcf.gz \
-O ${OUTDIR}/${SAMPLE}.genotype.g.vcf.gz \
-all-sites TRUE


echo ""
echo "done"
