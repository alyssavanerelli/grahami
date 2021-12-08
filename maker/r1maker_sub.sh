#!/bin/bash
#SBATCH --partition=p_ccib_1                            # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general                               # allows me to submit to cmain and main
#SBATCH --exclude=gpuc001,gpuc002                       # exclude CCIB GPUs
#SBATCH --job-name=maker_sub1                           # job name for listing in queue
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=0                                         # memory to allocate in Mb
#SBATCH -n 64
#SBATCH -N 2                                            # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --exclusive
#SBATCH --time=10-00:00:00                              # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                       # restart and paused or superseeded jobs
#SBATCH --mail-user=av795@rutgers.edu                   # email address to send status updates
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE              # email for the following reasons


cd /projects/f_geneva_1/alyssa/grahami/annotation

module purge
module load singularity/3.1.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

# NOTE: empty MAKER control files can be generated using the command:
#       singularity exec ${MAKER_IMAGE} maker -CTL 
# This will be needed at least for the maker_exe.ctl file, which has the paths to executables in the container.
# Otherwise, existing maker_bopts.ctl and maker_opts.ctl should be usable.

# Submit this job script from the directory with the MAKER control files


# optional repeat masking (if not using RepeatMasker, comment-out these three lines)
export SINGULARITYENV_LIBDIR=${PWD}/LIBDIR

#These commands need to be run once and then can be commented out for all subseqeunt MAKER RUNS
mkdir -p LIBDIR
singularity exec ${MAKER_IMAGE} sh -c 'ln -sf /usr/local/share/RepeatMasker/Libraries/* LIBDIR'

# singularity options:
# * --cleanenv : don't pass environment variables to container (except those specified in --env option-arguments)
# * --no-home : don't mount home directory (if not current working directory) to avoid any application/language startup files
# Add any MAKER options after the "maker" command
# * -nodatastore is suggested for Lustre, as it reduces the number of directories created
# * -fix_nucleotides needed for hsap_contig.fasta example data

singularity exec --no-home --cleanenv ${MAKER_IMAGE} mpiexec -n 64 maker -fix_nucleotides -nodatastore
