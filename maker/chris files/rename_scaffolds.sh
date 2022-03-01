#!/bin/sh
#SBATCH --partition=main
#SBATCH --job-name=canu_dneb1
#SBATCH --mem=32000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker

sortbyname.sh in=pilon_dneb1_cmp3.fasta out=pilon_dneb1_cmp3.sorted.fasta length descending

rename pilon_dneb1_cmp3.sorted.fasta
