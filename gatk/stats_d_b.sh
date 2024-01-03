#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=depth
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/stats/slurm-%j-%x.out
#SBATCH --mem=20G
#SBATCH -n 6
#SBATCH -N 1
#SBATCH --time=0-03:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module load java
module load samtools


BAM=$1

echo "${BAM}"

echo "depth stats"
samtools depth -a ${BAM} | awk '{c++;s+=$3}END{print s/c}'

echo ""
echo "breadth stats"
samtools depth -a ${BAM} | awk '{c++; if($3>0) total+=1}END{print (total/c)*100}'
