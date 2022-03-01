#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=maker_dneb1_aug3
#SBATCH --mem=128000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

export AUGUSTUS_CONFIG_PATH=/projectsc/ccib/geneva/chris/Augustus/config/

#Train Augustus gene models through BUSCO using the Augustus training variables from the previous run
busco -i /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output/snap/braker/dneb1_rnd3.all.maker.transcripts1000.fasta \
-f -o dneb1_rnd3_aug -l diptera_odb10 -m genome -c 30 --augustus --augustus_species Dnebulosa --long \
--augustus_parameters='--progress=true' >busco_aug_log.txt  2>&1
