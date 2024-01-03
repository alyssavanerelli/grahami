#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=addorreplace
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=50G
#SBATCH -n 10
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


echo "load variables"
SAMPLE=$1
BAM=$2
PU=$3
READ=$4
CORE=$5
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/add_replace"
BAM_DIR="/projects/f_geneva_1/alyssa/grahami/gatk/bam"

echo "run add or replace groups"
gatk AddOrReplaceReadGroups \
-I ${BAM_DIR}/${BAM} \
-O ${OUTDIR}/${SAMPLE}.addGP.bam \
-LB library1 -PL illumina -PU ${PU} -SM ${CORE}


echo "index reads"
samtools index ${OUTDIR}/${SAMPLE}.addGP.bam

echo "done"
