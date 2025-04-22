#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=snapshot
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/pretextmap/slurmout/slurm-%j-%x.out
#SBATCH --mem=60G
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load modules and conda environment"
module purge
module load samtools
eval "$(conda shell.bash hook)"
conda activate pretext

echo "run commands"
PretextSnapshot -m grahami.pretext --sequences "scaffold_1 > scaffold_18" --prefix grahami_full

PretextSnapshot -m grahami.pretext --sequences "scaffold_11,scaffold_12" --prefix grahami_sex_chrom

echo "done!"
