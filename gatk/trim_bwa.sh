#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=trim_bwa
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/fastqc/slurmout/slurm-%j-%x.out
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
module load FastQC
module load samtools
module load bwa


NAME=$1
DATA_DIR="/projects/f_geneva_1/data/sagrei_populations"
READS_OUTDIR="/projects/f_geneva_1/alyssa/sagrei/trimmed_reads"
FASTQC_OUTDIR="/projects/f_geneva_1/alyssa/sagrei/fastqc"
BAM_OUTDIR="/projects/f_geneva_1/alyssa/sagrei/bam"


echo "Bash commands for the analysis you are going to run"

echo "##################### fastqc initial quality analysis"
fastqc -t 20 \
${DATA_DIR}/${NAME}_R1.fastq.gz \
${DATA_DIR}/${NAME}_R2.fastq.gz \
-o ${FASTQC_OUTDIR}

cd ${READS_OUTDIR}

echo ""
echo "##################### trimmomatic"
java -jar /projects/f_geneva_1/programs/trimmomatic/trimmomatic-0.39.jar PE \
-threads 20 -phred33 -trimlog ${readset}_trim.log \
${DATA_DIR}/${NAME}_R1.fastq.gz ${DATA_DIR}/${NAME}_R2.fastq.gz \
${NAME}_filtered.R1.fq.gz ${NAME}_filtered.unpaired.R1.fq.gz \
${NAME}_filtered.R2.fq.gz ${NAME}_filtered.unpaired.R2.fq.gz \
ILLUMINACLIP:/projects/f_geneva_1/programs/trimmomatic/adapters/TruSeq3-PE-2.fa:2:30:10:4 \
LEADING:20 TRAILING:20 SLIDINGWINDOW:13:20 MINLEN:23

cd ${BASE_DIR}

echo ""
echo "##################### fastqc trimmomatic quality analysis"
fastqc -t 20 \
${READS_OUTDIR}/${NAME}_filtered.R1.fq.gz \
${READS_OUTDIR}/${NAME}_filtered.R2.fq.gz \
-o ${FASTQC_OUTDIR}


echo ""
echo "##################### index and align with BWA"
#bwa index /projects/f_geneva_1/alyssa/sagrei/genome/AnoSag2.1.fa

bwa mem -t 10 /projects/f_geneva_1/alyssa/sagrei/genome/AnoSag2.1.fa \
${READS_OUTDIR}/${NAME}_filtered.R1.fq \
${READS_OUTDIR}/${NAME}_filtered.R2.fq \
| samtools sort -@10 -o ${BAM_OUTDIR}/${NAME}_bwa_aligned.bam -


echo ""
echo "##################### index genome with samtools - only needs to be done once"
#samtools faidx /projects/f_geneva_1/alyssa/sagrei/genome/AnoSag2.1.fa


echo ""
echo "##################### index all bam files"
samtools index -b ${BAM_OUTDIR}/${NAME}_bwa_aligned.bam


echo ""
echo "done"
