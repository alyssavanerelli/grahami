#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=create_matrix
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/tads/slurmout/slurm-%j-%x.out
#SBATCH --mem=100G
#SBATCH -n 15
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load conda environment"
eval "$(conda shell.bash hook)"
conda activate hicexplorer

NAME=$1
BAM_OUTDIR="/projects/f_geneva_1/alyssa/grahami/tads/mapped_reads"
OUTDIR='/projects/f_geneva_1/alyssa/grahami/tads/matrix'

hicBuildMatrix --samFiles ${BAM_OUTDIR}/${NAME}_R1.bam ${BAM_OUTDIR}/${NAME}_R2.bam \
--binSize 10000 \
--restrictionSequence GATC \
--danglingSequence GATC \
--restrictionCutFile cut_sites.bed \
--threads 4 \
--inputBufferSize 100000 \
--outBam ${OUTDIR}/${NAME}_hic.bam \
-o ${OUTDIR}/${NAME}_hic_matrix.h5 \
--QCfolder ./${NAME}_hicQC

echo ""
echo "done"
