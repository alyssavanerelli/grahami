#!/bin/bash
#SBATCH --partition=p_ccib_1                            # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general	                        # allows me to submit to cmain and main
#SBATCH --exclude=gpuc001,gpuc002                       # exclude CCIB GPUs
#SBATCH --job-name=maker_bsh2                           # job name for listing in queue
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=128G                                     # memory to allocate in Mb
#SBATCH -n 16                                           # number of cores to use
#SBATCH -N 1                                            # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=8-00:00:00                               # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                       # restart and paused or superseeded jobs
#SBATCH --mail-user=av795@rutgers.edu                   # email address to send status updates
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE              # email for the following reasons

cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output/

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif


#Generate GFF files with and without the sequences
singularity exec ${MAKER_IMAGE} gff3_merge -s -d Agra_rnd2_master_datastore_index.log > Agra_rnd2.all.maker.gff
singularity exec ${MAKER_IMAGE} fasta_merge -d Agra_rnd2_master_datastore_index.log
# GFF w/o the sequences
singularity exec ${MAKER_IMAGE} gff3_merge -n -s -d Agra_rnd2_master_datastore_index.log > Agra_rnd2.all.maker.noseq.gff


mkdir snap
mkdir snap/braker
cd snap/braker
echo "# export 'confident' gene models from MAKER and rename to something meaningful"
singularity exec ${MAKER_IMAGE} maker2zff -n -d ../../Agra_rnd2_master_datastore_index.log
rename genome Agra_rnd2.zff.length5_aed0.5  *
echo "# gather some stats and validate"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd2.zff.length5_aed0.5.ann Agra_rnd2.zff.length5_aed0.5.dna -gene-stats > gene-stats.log 2>&1
singularity exec ${MAKER_IMAGE} fathom Agra_rnd2.zff.length5_aed0.5.ann Agra_rnd2.zff.length5_aed0.5.dna -validate > validate.log 2>&1
echo "# collect the training sequences and annotations, plus 1000 surrounding bp for training"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd2.zff.length5_aed0.5.ann Agra_rnd2.zff.length5_aed0.5.dna -categorize 1000 > categorize.log 2>&1
singularity exec ${MAKER_IMAGE} fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
echo "# create the training parameters"
mkdir params
cd params
singularity exec ${MAKER_IMAGE} forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

echo "# assembly the HMM"
singularity exec ${MAKER_IMAGE} hmm-assembler.pl Agra_rnd2.zff.length5_aed0.5 params > Agra_rnd2.zff.length5_aed0.5.hmm

awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ../../Agra_rnd2.all.maker.noseq.gff |   awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' |   bedtools getfasta -fi /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa -bed - -fo Agra_rnd2.all.maker.transcripts1000.fasta

