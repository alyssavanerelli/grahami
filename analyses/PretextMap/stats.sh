#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=stats
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/pretextmap/slurmout/slurm-%j-%x.out
#SBATCH --mem=220G
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
NAME=$1
INDIR="/projects/f_geneva_1/alyssa/grahami/pretextmap/files"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/pretextmap"

echo "run stats commands"
samtools flagstat ${OUTDIR}/${NAME}_bwa_aligned.bam

echo ""
echo "done"
