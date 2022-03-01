#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=maker_dneb1_aug2-trans
#SBATCH --mem=128000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

export AUGUSTUS_CONFIG_PATH=/projectsc/ccib/geneva/chris/Augustus/config/

#Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the dipter_odb10 transcript database
busco -i /scratch/cjs374/maker/maker_runs/pilon_dneb1_cmp3.maker.output.rnd2/pilon_dneb1_cmp3.all.maker.transcripts.fasta \
-o dneb1_annotation_eval2 -l diptera_odb10 -m transcriptome -c 8 --augustus_species Dnebulosa \
--augustus_parameters='--progress=true' >busco_aug_rnd2_transc.txt
