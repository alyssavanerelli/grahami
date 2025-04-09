#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=bwa
#SBATCH --output=/projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/slurmout/slurm-%j-%x.out
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
DATA="/projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/data"
INDIR="/projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/reads"
OUTDIR="/projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/bam"
STATS="/projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/bam/stats"

echo ""
echo "##################### index and align with BWA"
#bwa index ${DATA}/grahami_mtdna.fasta

bwa mem -t 10 ${DATA}/grahami_mtdna.fasta \
${INDIR}/${NAME}_filtered.R1.fq.gz \
${INDIR}/${NAME}_filtered.R2.fq.gz \
| samtools sort -@10 -o ${OUTDIR}/${NAME}_bwa_aligned.bam -


echo ""
echo "##################### index genome with samtools - only needs to be done once"
#samtools faidx ${DATA}/grahami_mtdna.fasta


echo ""
echo "##################### index all bam files"
samtools index -b ${OUTDIR}/${NAME}_bwa_aligned.bam

echo ""
echo "done"
