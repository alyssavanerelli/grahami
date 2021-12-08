# BUSCO_PHYLOGENOMICS

## Gather Genomes
download genome sequence files from NCBI (or other places) in FASTA format
```
cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes
wget [link]
```

Proceed to unzip file and rename

## run BUSCO on all genomes

busco.sh file
```
#!/bin/bash
#SBATCH --partition=cmain                    # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
#SBATCH --job-name=busco                     # job name for listing in queue
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/busco_out/slurmout/slurm-%j-%x.out
#SBATCH --mem=150G                              # memory to allocate in Mb
#SBATCH -n 1                                   # number of cores to use
#SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=3-00:00:00                       # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                               # restart and paused or superseeded jobs
#SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
#SBATCH --mail-type=FAIL,END                    # email for the following reasons


eval "$(conda shell.bash hook)"
conda activate busco

FASTA=$1

echo "${FASTA}"

echo "Bash commands for the analysis you are going to run"
busco -i /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/${FASTA} -c 16 -l vertebrata_odb10 -o ${FASTA} -m genome
```

then create a loop.sh to cycle through all the genome fasta files in a folder

run_busco.sh
```
#!/bin/bash
FILES=$(ls -1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/*.fa | cut -d "/" -f 9 | sort)
for FILE in $FILES
do
  sbatch busco.sh "$FILE"
  sleep 0.25
  #echo "$FILE"
done
```

to submit this job: `./run_busco.sh`
















