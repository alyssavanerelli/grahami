#!/bin/sh
#SBATCH --partition=p_ccib_1
#SBATCH --job-name=r2maker_dneb_sub
#SBATCH --nodes=1
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --time=4-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE









cd /scratch/cjs374/maker/

module purge
module load singularity/3.1.0

MAKER_IMAGE=/projects/ccib/geneva/programs/maker:2.31.11-repbase.sif

# NOTE: empty MAKER control files can be generated using the command:
#       singularity exec ${MAKER_IMAGE} maker -CTL 
# This will be needed at least for the maker_exe.ctl file, which has the paths to executables in the container.
# Otherwise, existing maker_bopts.ctl and maker_opts.ctl should be usable.

# Submit this job script from the directory with the MAKER control files


# optional repeat masking (if not using RepeatMasker, comment-out these three lines)
export SINGULARITYENV_LIBDIR=${PWD}/LIBDIR

#Set Augustus PATH
export SINGULARITYENV_AUGUSTUS_CONFIG_PATH=/projectsc/ccib/geneva/chris/Augustus/config/
export SINGULARITYENV_AUGUSTUS_SCRIPTS_PATH=/projectsc/ccib/geneva/chris/Augustus/scripts
export SINGULARITYENV_AUGUSTUS_BIN_PATH=/projectsc/ccib/geneva/chris/Augustus/bin

#These commands need to be run once and then can be commented out for all subseqeunt MAKER RUNS
#mkdir -p LIBDIR
#singularity exec ${MAKER_IMAGE} sh -c 'ln -sf /usr/local/share/RepeatMasker/Libraries/* LIBDIR'

# singularity options:
# * --cleanenv : don't pass environment variables to container (except those specified in --env option-arguments)
# * --no-home : don't mount home directory (if not current working directory) to avoid any application/language startup files
# Add any MAKER options after the "maker" command
# * -nodatastore is suggested for Lustre, as it reduces the number of directories created
# * -fix_nucleotides needed for hsap_contig.fasta example data
singularity exec --no-home --cleanenv ${MAKER_IMAGE} mpiexec -n ${SLURM_CPUS_ON_NODE} maker -fix_nucleotides
