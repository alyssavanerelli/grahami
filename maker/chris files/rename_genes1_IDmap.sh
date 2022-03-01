#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=rename_genes
#SBATCH --mem=8000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=02:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/

module load singularity/3.1.0

MAKER_IMAGE=/projects/ccib/geneva/programs/maker:2.31.11-repbase.sif

#Map MAKER IDs to numerical IDs with a specified prefix
singularity exec $MAKER_IMAGE  maker_map_ids --prefix DNEB_ --justify 6 \
pilon_dneb1_cmp3.maker.output.rnd3/dneb1_rnd3.all.maker.gff > pilon_dneb1_cmp3.maker.output.rnd3/dneb1_rnd3.all.maker.map
