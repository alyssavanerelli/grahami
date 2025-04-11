#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=merge
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/pretextmap/slurmout/slurm-%j-%x.out
#SBATCH --mem=200G
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

echo "load variables"
READ1="DTG-HiC-103"
READ2="DTG-HiC-104"
READ3="DTG-HiC-105"

echo "run commands"
samtools merge -o hic_merged.bam \
${READ1}_bwa_aligned.bam \
${READ2}_bwa_aligned.bam \
${READ3}_bwa_aligned.bam 

echo ""
echo "done!"
