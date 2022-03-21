#!/bin/bash
#SBATCH --partition=p_ccib_1 	                    	# which partition to run the job, options are in the Amarel guide
#SBATCH --account=general				# allows me to submit to cmain and main
#SBATCH --exclude=gpuc001,gpuc002               	# exclude CCIB GPUs
#SBATCH --job-name=maker_aug2                     	# job name for listing in queue
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=90G                              	# memory to allocate in Mb
#SBATCH -n 16                                   	# number of cores to use
#SBATCH -N 1                                    	# number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=8-00:00:00                       	# maximum run time days-hours:minutes:seconds
#SBATCH --requeue                               	# restart and paused or superseeded jobs
#SBATCH --mail-user=av795@rutgers.edu           	# email address to send status updates
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE      	# email for the following reasons


echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif



eval "$(conda shell.bash hook)"
conda activate busco


export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config 

#Train Augustus gene models through BUSCO using the vertebrata_odb10 dataset
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output/snap/braker/Agra_rnd2.all.maker.transcripts1000.fasta \
-f -o Agra_rnd2_aug --offline -l vertebrata_odb10 -m genome -c 30 --augustus --augustus_species Anolis_grahami --long \
--augustus_parameters='--progress=true' >busco_aug_log.txt  2>&1

