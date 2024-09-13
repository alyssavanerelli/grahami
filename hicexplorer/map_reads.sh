#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=map_reads
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/hicexplorer/slurmout/slurm-%j-%x.out
#SBATCH --mem=100G
#SBATCH -n 15
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load modules"
module purge
module load java 
module load samtools
module load bwa

echo ""
echo "variables"
NAME=$1
READS_INDIR="/projects/f_geneva_1/data/denovo_genomes/grahami_fixed"
READS_OUTDIR="/projects/f_geneva_1/alyssa/grahami/hicexplorer/mapped_reads"
BAM_OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/bam"

echo ""
echo "##################### index and align with BWA"
bwa index /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa

bwa mem -t 10 /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa \
${READS_OUTDIR}/${NAME}_filtered.R1.fq.gz \
${READS_OUTDIR}/${NAME}_filtered.R2.fq.gz \
| samtools sort -@10 -o ${BAM_OUTDIR}/${NAME}_bwa_aligned.bam -


echo ""
echo "##################### index genome with samtools - only needs to be done once"
#samtools faidx /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa


echo ""
echo "##################### index all bam files"
samtools index -b ${BAM_OUTDIR}/${NAME}_bwa_aligned.bam


echo ""
echo "done"









# map the reads, each mate individually using
# for example bwa
#
# bwa mem mapping options:
#       -A INT        score for a sequence match, which scales options -TdBOELU unless overridden [1]
#       -B INT        penalty for a mismatch [4]
#       -O INT[,INT]  gap open penalties for deletions and insertions [6,6]
#       -E INT[,INT]  gap extension penalty; a gap of size k cost '{-O} + {-E}*k' [1,1] # this is set very high to avoid gaps
#                                  at restriction sites. Setting the gap extension penalty high, produces better results as
#                                  the sequences left and right of a restriction site are mapped independently.
#       -L INT[,INT]  penalty for 5'- and 3'-end clipping [5,5] # this is set to no penalty.

$ bwa mem -A1 -B4  -E50 -L0  index_path \
    mate_R1.fastq.gz 2>>mate_R1.log | samtools view -Shb - > mate_R1.bam

$ bwa mem -A1 -B4  -E50 -L0  index_path \
    mate_R2.fastq.gz 2>>mate_R2.log | samtools view -Shb - > mate_R2.bam
