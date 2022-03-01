#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=rename_gag
#SBATCH --mem=16000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=05:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output.rnd3.renamed

#Associate gene names with MAKER ID using the Annie generated MAP
python2.7 /home/cjs374/genomeannotation-GAG-997e384/gag.py \
-f ../pilon_dneb1_cmp3.fasta \
-g dneb1_rnd3.all.maker.gff \
-a annie_neb2sprot.tsv \
-o annotsprot
