# BUSCO_PHYLOGENOMICS
this pipeline runs directly on the output from BUSCO

![Image](https://github.com/jamiemcg/BUSCO_phylogenomics/blob/master/pipeline.png?raw=true)

**Requirements**
- [x] [Python](https://www.python.org/)
- [x] [BioPython](https://biopython.org/)
  - use `pip` to install 
  ```
  pip install biopython
  pip install --upgrade biopython
  pip uninstall biopython
  ```
- [ ] [MUSCLE](https://www.drive5.com/muscle/)
  - [download links here](https://github.com/rcedgar/muscle/releases/tag/v5.0.1428)
- [ ] [trimAl](http://trimal.cgenomics.org/)
  - [download links here](http://trimal.cgenomics.org/downloads)
- [ ] [IQ-TREE](http://www.iqtree.org/)
  - [download links here](http://www.iqtree.org/)

`muscle`, `trimal`, and `iqtree` should be in `$PATH`

**to check for these programs**

`which [program]` or `module spider [program]` (in this case you would need to load these programs before running job with `module load [program]`)

**to add these programs to `$PATH`**

download `wget` program while in `/home/av795/bin`?

## directory structure
- `busco`
  - `busco_phylogenomics`
    - `genomes`
      - contains fasta genome files
    - `busco_out`
      - contains slurm file (this is where I run the job)
      - results from BUSCO runs
      - `slurmout`
        - slurm output files from jobs

## Gather Genomes
download genome sequence files from NCBI (or other places) in FASTA format
```
cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes
wget [link]
```

Proceed to unzip file and rename

## run BUSCO on all genomes

**busco.sh file**
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

echo "Bash commands for the analysis you are going to run"
busco -i /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/${FASTA} -c 16 -l vertebrata_odb10 -o ${FASTA} -m genome
```

then create a loop.sh to cycle through all the genome fasta files in a folder

**run_busco.sh**
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

- In addition, move over BUSCO analysis ran on final assembly to this folder: `busco_out`

## create directory of BUSCO results

```
mkdir input_dir

```

## Running busco_phylogenomics

```
python BUSCO_Phylogenomics.py -d INPUT_DIRECTORY -o OUTPUT_DIRECTORY --supermatrix --threads 20
```

**Required Parameters**
- `-d --directory`: input directory containing BUSCO runs
- `-o --output`: output directory
- `-t --threads`: number of threads to use
- `--supermatrix` and/or `--supertree`: choose to run supermatrix and/or supertree methods

**Optional Parameters**
- `-psc`: BUSCO families that are present and single-copy in N% of species will be included in supermatrix analysis (default = 100%). Families that are missing for a species will be replaced with missing characters ("?").
- `--stop_early`: stop pipeline early before phylogenetic inference (i.e., for the supermatrix approach this will stop after generating the concatenated alignment). This is **recommended** so you can manually choose your own parameters (e.g., bootstrapping/model selection methods) or manually processing/filtering the alignments further when running IQ-Tree, etc..



**code for _Anolis grahami_**
```
python BUSCO_Phylogenomics.py
```







