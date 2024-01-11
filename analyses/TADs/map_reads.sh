#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=map_hic_reads
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/tads/slurmout/slurm-%j-%x.out
#SBATCH --mem=100G
#SBATCH -n 15
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load any Amarel modules that script requires"
module purge
module load java 
module load samtools
module load bwa

NAME=$1
READS_OUTDIR="/projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra/fastq"
BAM_OUTDIR="/projects/f_geneva_1/alyssa/grahami/tads/mapped_reads"

echo ""
echo "##################### index and align with BWA"
# bwa index /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa

echo ""
echo "R1 files"
bwa mem -A1 -B4  -E50 -L0 -t 10 /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa \
${READS_OUTDIR}/${NAME}_R1_001.fastq.gz 2>>${BAM_OUTDIR}/${NAME}_R1.log | samtools view -Shb - > ${BAM_OUTDIR}/${NAME}_R1.bam

echo ""
echo "R2 files"
bwa mem -A1 -B4  -E50 -L0 -t 10 /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa \
${READS_OUTDIR}/${NAME}_R2_001.fastq.gz 2>>${BAM_OUTDIR}/${NAME}_R2.log | samtools view -Shb - > ${BAM_OUTDIR}/${NAME}_R2.bam

echo ""
echo "##################### index all bam files"
samtools index -b ${BAM_OUTDIR}/${NAME}_R1.bam
samtools index -b ${BAM_OUTDIR}/${NAME}_R2.bam

echo ""
echo "done"
