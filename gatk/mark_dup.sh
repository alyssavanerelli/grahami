#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=MarkDup
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=180G
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


echo ""
echo "load variables"
#SAMPLE=$1
SAMPLE='DTG-SG-149'
INDIR="/projects/f_geneva_1/alyssa/grahami/gatk/add_replace"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/mark_duplicates"


echo ""
echo "run mark duplicates"
gatk MarkDuplicates \
--java-options "-Xms200G -Xmx240g" \
-I ${INDIR}/${SAMPLE}.addGP.bam \
-O ${OUTDIR}/${SAMPLE}.marked.bam \
-M ${OUTDIR}/${SAMPLE}.metrics.txt \
--REMOVE_DUPLICATES false --ASSUME_SORTED true --CREATE_INDEX true

echo ""
echo "done"
