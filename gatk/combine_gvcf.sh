#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --constraint=oarc
#SBATCH --job-name=combine
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=20G
#SBATCH -n 5
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
#INDIR="/projects/f_geneva_1/alyssa/grahami/gatk/mark_duplicates"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/haplotype_caller"
BASE_DIR='/projects/f_geneva_1/alyssa/grahami/gatk'

echo ""
echo "combine gVCFs"
gatk \
--java-options "-Xms15G -Xmx20g -XX:ParallelGCThreads=5" \
CombineGVCFs \
-R ${GEN_DIR}/AnoGra1.1.fa \
--variant ${BASE_DIR}/combine.list \
-O ${OUTDIR}/${SAMPLE}.g.vcf.gz

echo ""
echo "index gVCF file"
gatk \
IndexFeatureFile \
-I ${OUTDIR}/${SAMPLE}.g.vcf.gz

echo ""
echo "done"
