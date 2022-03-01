#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=rename_genes_function
#SBATCH --mem=16000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=05:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output.rnd3.renamed/

module load singularity/3.1.0

MAKER_IMAGE=/projects/ccib/geneva/programs/maker:2.31.11-repbase.sif

#Append the gene names from the BLASTP results to each associated gene prediction

#Master GFF
singularity exec $MAKER_IMAGE  maker_functional_gff ../proteomes/uniprot_sprot.fasta \
neb_maker2sprot.blastp dneb1_rnd3.all.maker.gff \
dneb1_rnd3.all.maker.functional_blast.gff

#Protein FASTA
singularity exec $MAKER_IMAGE maker_functional_fasta ../proteomes/uniprot_sprot.fasta \
neb_maker2sprot.blastp pilon_dneb1_cmp3.all.maker.proteins.fasta \
pilon_dneb1_cmp3.all.maker.proteins_functional_blast.fasta

#Transcript FASTA
singularity exec $MAKER_IMAGE maker_functional_fasta ../proteomes/uniprot_sprot.fasta \
neb_maker2sprot.blastp pilon_dneb1_cmp3.all.maker.transcripts.fasta \
pilon_dneb1_cmp3.all.maker.transcripts_functional_blast.fasta

#Check for correct annotation in master GFF and BLASTP output
head -n 4 dneb1_rnd3.all.maker.functional_blast.gff
head -n 1 pilon_dneb1_cmp3.all.maker.proteins_functional_blast.fasta
