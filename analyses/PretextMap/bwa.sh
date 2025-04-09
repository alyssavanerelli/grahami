#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=bwa
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/pretextmap/slurmout/slurm-%j-%x.out
#SBATCH --mem=200G
#SBATCH -n 15
#SBATCH -N 1
#SBATCH --time=7-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load any Amarel modules that script requires"
module purge
module load java 
module load samtools
module load bwa

NAME=$1
INDIR="/projects/f_geneva_1/alyssa/grahami/pretextmap/files"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/pretextmap"

echo ""
echo "##################### index and align with BWA"
#bwa index ${INDIR}/AnoGra1.1.fa

bwa mem -t 10 ${INDIR}/AnoGra1.1.fa \
${INDIR}/${NAME}_R1_001.fastq.gz \
${INDIR}/${NAME}_R2_001.fastq.gz \
| samtools sort -@10 -o ${OUTDIR}/${NAME}_bwa_aligned.bam -


echo ""
echo "##################### index genome with samtools - only needs to be done once"
#samtools faidx ${INDIR}/AnoGra1.1.fa


echo ""
echo "##################### index all bam files"
samtools index -b ${OUTDIR}/${NAME}_bwa_aligned.bam

echo ""
echo "done"
