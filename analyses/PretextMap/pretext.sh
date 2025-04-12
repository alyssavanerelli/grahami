#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=pretextmap
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/pretextmap/slurmout/slurm-%j-%x.out
#SBATCH --mem=60G
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --time=2-18:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "load modules and conda environment"
module purge
module load samtools
eval "$(conda shell.bash hook)"
conda activate pretext

echo "run commands"
samtools view -h hic_merged.bam | PretextMap -o grahami.pretext --sortby length --sortorder descend --mapq 30

echo "done!"
