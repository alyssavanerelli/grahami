#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=rename_genes_change_ids
#SBATCH --mem=16000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=05:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output.rnd3/

module load singularity/3.1.0

MAKER_IMAGE=/projects/ccib/geneva/programs/maker:2.31.11-repbase.sif

#Changes the IDs of a given GFF/FASTA file based off of a MAP

#Master GFF
singularity exec $MAKER_IMAGE map_gff_ids \
dneb1_rnd3.all.maker.map dneb1_rnd3.all.maker.gff

#Protein FASTA
singularity exec $MAKER_IMAGE map_fasta_ids \
dneb1_rnd3.all.maker.map pilon_dneb1_cmp3.all.maker.proteins.fasta

#Transcript fasta
singularity exec $MAKER_IMAGE map_fasta_ids \
dneb1_rnd3.all.maker.map pilon_dneb1_cmp3.all.maker.transcripts.fasta

#Check for changes in the first three lines of the master GFF
head -n 3 dneb1_rnd3.all.maker.gff
