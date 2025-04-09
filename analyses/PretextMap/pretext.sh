#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=filter_variants
#SBATCH --output=/projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/slurmout/slurm-%j-%x.out
#SBATCH --mem=40G
#SBATCH -n 2
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

samtools view -h mapped_hifi_hic_yahs.bam | PretextMap -o dist.pretext --sortby length --sortorder descend --mapq 30









