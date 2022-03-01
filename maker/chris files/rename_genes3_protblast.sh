#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=rename_genes_func
#SBATCH --mem=16000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=05:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/

module purge
module load singularity/3.1.0
module load blast/2.6.0

MAKER_IMAGE=/projects/ccib/geneva/programs/maker:2.31.11-repbase.sif

#Using a closely related species, find the highest matching ortholog of each gene prediction using BLASTP 
blastp -db proteomes/uniprot_sprot.fasta \
-query pilon_dneb1_cmp3.maker.output.rnd3.renamed/pilon_dneb1_cmp3.all.maker.proteins.fasta \
-out neb_maker2sprot.blastp -evalue .000001 -outfmt 6 -num_alignments 1 -seg yes -soft_masking true \
-lcase_masking -max_hsps 1

