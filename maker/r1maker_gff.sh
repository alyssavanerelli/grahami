#!/bin/bash
#SBATCH --partition=p_ccib_1                            # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general                               # allows me to submit to cmain and main
#SBATCH --exclude=gpuc001,gpuc002                       # exclude CCIB GPUs
#SBATCH --job-name=maker_gff1                           # job name for listing in queue
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=32000                                     # memory to allocate in Mb
#SBATCH -n 8                                            # number of cores to use
#SBATCH -N 1                                            # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=0-05:00:00                               # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                       # restart and paused or superseeded jobs
#SBATCH --mail-user=av795@rutgers.edu                   # email address to send status updates
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE              # email for the following reasons


cd /projects/f_geneva_1/alyssa/grahami/annotation/AnoGra1.1.maker.output

# transcript alignments
awk '{ if ($2 == "est2genome") print $0 }' AnoGra_rnd1.all.maker.noseq.gff > AnoGra_rnd1.all.maker.est2genome.gff
# protein alignments
awk '{ if ($2 == "protein2genome") print $0 }' AnoGra_rnd1.all.maker.noseq.gff > AnoGra_rnd1.all.maker.protein2genome.gff
# repeat alignments
awk '{ if ($2 ~ "repeat") print $0 }' AnoGra_rnd1.all.maker.noseq.gff > AnoGra_rnd1.all.maker.repeats.gff
