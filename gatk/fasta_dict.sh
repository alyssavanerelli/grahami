#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=dict
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=60G
#SBATCH -n 15
#SBATCH -N 1
#SBATCH --time=1-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

echo "######################## modules"

module purge
module use /projects/community/modulefiles/
module load GATK/4.2.2.0-yc759
module load bedtools2/2.25.0
module load gcc/7.3.0-gc56

echo ""
echo "create file"
gatk CreateSequenceDictionary -R /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa

echo ""
echo "done"
