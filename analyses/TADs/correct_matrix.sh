#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=correct_matrix
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/tads/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load conda environment"
eval "$(conda shell.bash hook)"
conda activate hicexplorer

echo ""
echo "load variables"
FASTA_DIR='/projects/f_geneva_1/alyssa/grahami'
BAM_OUTDIR="/projects/f_geneva_1/alyssa/grahami/tads/mapped_reads"
OUTDIR='/projects/f_geneva_1/alyssa/grahami/tads/matrix'

echo ""
echo "run commands"
# hicCorrectMatrix diagnostic_plot -m ${OUTDIR}/DTG-HiC-103_hic_matrix.h5 -o ${OUTDIR}/DTG-HiC-103_hic_matrix.png
# hicCorrectMatrix correct -m ${OUTDIR}/DTG-HiC-103_hic_matrix.h5 --filterThreshold -2 4 -o ${OUTDIR}/DTG-HiC-103_hic_corrected.h5

echo ""
echo "done"
