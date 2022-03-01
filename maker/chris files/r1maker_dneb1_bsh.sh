#!/bin/sh
#SBATCH --partition=main
#SBATCH --job-name=maker_dneb1_bsh1
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=1-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output/

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/ccib/geneva/programs/maker:2.31.11-repbase.sif


#Generate GFF files with and without the sequences
singularity exec ${MAKER_IMAGE} gff3_merge -s -d pilon_dneb1_cmp3_master_datastore_index.log > dneb1_rnd1.all.maker.gff
singularity exec ${MAKER_IMAGE} fasta_merge -d pilon_dneb1_cmp3_master_datastore_index.log
# GFF w/o the sequences
singularity exec ${MAKER_IMAGE} gff3_merge -n -s -d pilon_dneb1_cmp3_master_datastore_index.log > dneb1_rnd1.all.maker.noseq.gff


mkdir snap
mkdir snap/braker
cd snap/braker
# export 'confident' gene models from MAKER and rename to something meaningful
singularity exec ${MAKER_IMAGE} maker2zff -x 0.25 -l 50 -d ../../pilon_dneb1_cmp3_master_datastore_index.log
rename 's/genome/dneb1_rnd1.zff.length50_aed0.25/g'  *
# gather some stats and validate
singularity exec ${MAKER_IMAGE} fathom dneb1_rnd1.zff.length50_aed0.25.ann dneb1_rnd1.zff.length50_aed0.25.dna -gene-stats > gene-stats.log 2>&1
singularity exec ${MAKER_IMAGE} fathom dneb1_rnd1.zff.length50_aed0.25.ann dneb1_rnd1.zff.length50_aed0.25.dna -validate > validate.log 2>&1
# collect the training sequences and annotations, plus 1000 surrounding bp for training
singularity exec ${MAKER_IMAGE} fathom dneb1_rnd1.zff.length50_aed0.25.ann dneb1_rnd1.zff.length50_aed0.25.dna -categorize 1000 > categorize.log 2>&1
singularity exec ${MAKER_IMAGE} fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
# create the training parameters
mkdir params
cd params
singularity exec ${MAKER_IMAGE} forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

# assembly the HMM
hmm-assembler.pl dneb1_rnd1.zff.length50_aed0.25 params > dneb1_rnd1.zff.length50_aed0.25.hmm

awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ../../dneb1_rnd1.all.maker.noseq.gff |   awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' |   bedtools getfasta -fi /scratch/cjs374/maker/pilon_dneb1_cmp3.fasta -bed - -fo dneb1_rnd1.all.maker.transcripts1000.fasta
