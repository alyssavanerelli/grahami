#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=rename_annie_sprot
#SBATCH --mem=16000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=05:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output.rnd3.renamed

#Map BLASTP results to MAKER gene IDs 
python3 /home/cjs374/genomeannotation-annie-4bb3980/annie.py \
-b neb_maker2sprot.blastp \
-g dneb1_rnd3.all.maker_wo_semis.gff \
-db ../proteomes/uniprot_sprot.fasta
