#!/bin/bash
#SBATCH --partition=p_geneva_1
#SBATCH --exclude=gpuc001,gpuc002,halc068
#SBATCH --job-name=gatk_HC
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=60G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=3-16:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load GATK/4.2.2.0-yc759
module load samtools


echo ""
echo "load variables"
#SAMPLE=$1
LIST=$1
SAMPLE='DTG-SG-149'
INDIR="/projects/f_geneva_1/alyssa/grahami/gatk/mark_duplicates"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/haplotype_caller"
BASE_DIR='/projects/f_geneva_1/alyssa/grahami/gatk'

echo ""
echo "run haplotype caller"
gatk --java-options "-Xms58G -Xmx60g -XX:ParallelGCThreads=2" HaplotypeCaller --native-pair-hmm-threads 2 \
-I ${INDIR}/${SAMPLE}.marked.bam \
-O ${OUTDIR}/${SAMPLE}.g.vcf.gz \
-R ${GEN_DIR}/AnoGra1.1.fa \
-ERC BP_RESOLUTION \
--output-mode EMIT_ALL_CONFIDENT_SITES \
--max-reads-per-alignment-start 0 \
-RF NotDuplicateReadFilter \
-L ${BASE_DIR}/${LIST}

echo ""
echo "done"
