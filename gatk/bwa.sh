#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=trim_bwa
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
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


#NAME=$1
NAME="DTG-SG-149"
READS_OUTDIR="/projects/f_geneva_1/alyssa/grahami"
DATA_DIR="/projects/f_geneva_1/data/sagrei_populations"
BAM_OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/bam"

echo ""
echo "##################### index and align with BWA"
bwa index /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa

bwa mem -t 10 /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa \
${READS_OUTDIR}/${NAME}_filtered.R1.fq \
${READS_OUTDIR}/${NAME}_filtered.R2.fq \
| samtools sort -@10 -o ${BAM_OUTDIR}/${NAME}_bwa_aligned.bam -


echo ""
echo "##################### index genome with samtools - only needs to be done once"
#samtools faidx /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa


echo ""
echo "##################### index all bam files"
samtools index -b ${BAM_OUTDIR}/${NAME}_bwa_aligned.bam


echo ""
echo "done"
