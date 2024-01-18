#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=find_rest_site
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
hicFindRestSite --fasta ${FASTA_DIR}/AnoGra1.1.fa --searchPattern ACGT -o ${OUTDIR}/rest_site_positions.bed

echo""
echo "done"
