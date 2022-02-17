# BUSCO_PHYLOGENOMICS
this pipeline runs directly on the output from BUSCO

[github page](https://github.com/jamiemcg/BUSCO_phylogenomics)

![Image](https://github.com/jamiemcg/BUSCO_phylogenomics/blob/master/pipeline.png?raw=true)

**Requirements**
- [x] [Python](https://www.python.org/)
- [x] [BioPython](https://biopython.org/)
  - [github page](https://github.com/biopython/biopython)
  - use `pip` to install 
  ```
  pip install biopython
  pip install --upgrade biopython
  pip uninstall biopython
  ```
- [x] [MUSCLE](https://www.drive5.com/muscle/)
  - [download links here](https://github.com/rcedgar/muscle/releases/tag/v5.0.1428)
  - NEED TO USE VERSION 3
    <details><summary>code</summary>
    <p>
    
      ```
    cd
    wget [link]
    mv muscle_v5.0.1428_linux muscle
    chmod 755 muscle
    mv muscle bin/
      ```
    </p>
    </details>
    
- [x] [trimAl](http://trimal.cgenomics.org/)
  - [download links here](http://trimal.cgenomics.org/downloads)
    <details><summary>code</summary>
    <p>
    
    ```
    # download, unzip, and untar file
    cd
    wget [link]
    gunzip trimal.v1.2rev59.tar.gz
    tar -xvf trimal.v1.2rev59.tar
    
    #compile package
    cd trimAl/source
    make
    
    # move `readal` and `trimal` (result of previous step) to `bin/`
    mv readal trimal bin/
    ```
    </p>
    </details>
    
- [x] [IQ-TREE](http://www.iqtree.org/)
  - [download links here](http://www.iqtree.org/)
  - 
    
    <details><summary>code</summary>
    <p>
    
    ```
    cd
    conda install -c bioconda iqtree
    ```
    
    </p>
    </details>

`muscle`, `trimal`, and `iqtree` should be in `$PATH`

**to check for these programs**

`which [program]` or `module spider [program]` (in this case you would need to load these programs before running job with `module load [program]`)
- all the programs are installed in path so nothing will need to be manually loaded

`biopython` will be installed as a python package so to check run `pip list` and search for `biopython` and `numpy` in the output list

to check that all programs are installed _properly_ run `[program] -h` and the help page should print

**to add these programs to `$PATH`**

either need to be in /home/av795/bin or add downloaded folder to path in `.bash_profile`

## directory structure
- `busco/`
  - `busco_phylogenomics/`
    - `genomes/`
      - contains fasta genome files
    - `busco_out/`
      - contains slurm file (this is where I run the job)
      - results from BUSCO runs
      - `slurmout/`
        - slurm output files from jobs
    - `phy_input/`
      - directory where busco results will need to be moved to use as input for busco_phylogenomics
    - `phy_output/`
      - directory where output from busco_phylogenomics will go
    - `slurmout/`
      - where slurm output file for busco_phylogenomics run will go
    - `phy_sub.sh`
      - submission script for busco_phylogenomics

## Gather Genomes
download genome sequence files from NCBI (or other places) in FASTA format
```
cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes
wget [link]
```

Proceed to unzip files and rename

## run BUSCO on all genomes

<details><summary>busco.sh file</summary>
<p>
  
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

<p>
</details>

then create a loop.sh to cycle through all the genome fasta files in a folder


<details><summary>run_busco.sh file</summary>
<p>

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

<p>
</details>

to submit this job: `./run_busco.sh`

- In addition, move over BUSCO analysis ran on final assembly to this folder: `busco_out`


## Running busco_phylogenomics
1. activate conda busco environment or make new conda environment
```
conda activate busco
```
2. move results from busco to new input directory
```
cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics
mkdir phy_input
cp busco_out/*.fa phy_input/
```
3. create output directory
```
mkdir phy_output
```
4. run busco_phylogenomics on BUSCO results
<details><summary>general code</summary>

```
python BUSCO_Phylogenomics.py -d INPUT_DIRECTORY -o OUTPUT_DIRECTORY --supermatrix --threads 20
```

</p>
</details>

**Required Parameters**
- `-d --directory`: input directory containing BUSCO runs
- `-o --output`: output directory
- `-t --threads`: number of threads to use
- `--supermatrix` and/or `--supertree`: choose to run supermatrix and/or supertree methods

**Optional Parameters**
- `-psc`: BUSCO families that are present and single-copy in N% of species will be included in supermatrix analysis (default = 100%). Families that are missing for a species will be replaced with missing characters ("?").
- `--stop_early`: stop pipeline early before phylogenetic inference (i.e., for the supermatrix approach this will stop after generating the concatenated alignment). This is **recommended** so you can manually choose your own parameters (e.g., bootstrapping/model selection methods) or manually processing/filtering the alignments further when running IQ-Tree, etc..


**_Anolis grahami_ code**
```
python BUSCO_Phylogenomics.py -d phy_input -o phy_output --supermatrix --threads 20
```
_remember that busco conda environment must be activated before submitting submission script_

<details><summary>phy_sub.sh</summary>
  <p>
    
    ```
    #!/bin/bash
    #SBATCH --partition=p_ccib_1                    # which partition to run the job, options are in the Amarel guide
    #SBATCH --account=general
    #SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
    #SBATCH --job-name=buscophy                     # job name for listing in queue
    #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/slurmout/slurm-%j-%x.out
    #SBATCH --mem=160G                              # memory to allocate in Mb
    #SBATCH -n 20                                   # number of cores to use
    #SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
    #SBATCH --time=3-00:00:00                       # maximum run time days-hours:minutes:seconds
    #SBATCH --requeue                               # restart and paused or superseeded jobs
    #SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
    #SBATCH --mail-type=BEGIN,REQUEUE, FAIL,END     # email for the following reasons

    
    python BUSCO_Phylogenomics.py -d phy_input -o phy_output --supermatrix --threads 20
    ```
    
  </p>
  </details>
  


5. visualize results

A file named `SUPERMATRIX.aln.treefile` will be created in the `phy_out` directory. The results of this file can be copied and pasted into [iTOL](https://itol.embl.de/) to visualize your tree!


## Output

### Supermatrix


### Supertree

1. When submitting script, use `--supertree`
2. Download ASTRAL
  - [ASTRAL github page](https://github.com/smirarab/ASTRAL)
  - [ASTRAL github tutorial page](https://github.com/smirarab/ASTRAL/blob/master/astral-tutorial.md)
  - I installed via git clone, then unzipped the jar file, moved all of astral download to bin
3. For astral help (display options)
  ```
  java -jar /home/av795/bin/ASTRAL/Astral/astral.5.7.8.jar
  ```

**Path to jar file**
```
/home/av795/bin/ASTRAL/Astral/astral.5.7.8.jar
```

3. The output file that we will use from supertree analysis in busco_phylogenomics: `ALL.trees`

4. Make `astral.sh` to submit species tree analysis


<details><summary>astral.sh</summary>
<p>
  
  ```
  #!/bin/bash

#SBATCH --partition=p_ccib_1                    # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
#SBATCH --job-name=astral                       # job name for listing in queue
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/astral/slurmout/slurm-%j-%x.out
#SBATCH --mem=160G                              # memory to allocate in Mb
#SBATCH -n 20                                   # number of cores to use
#SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=3-00:00:00                       # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                               # restart and paused or superseeded jobs
#SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
#SBATCH --mail-type=BEGIN,REQUEUE, FAIL,END     # email for the following reasons


echo "########### load any modules needed"
module purge
module load java



echo ""
echo "########### commands for analysis you are going to run"

phylogeny="/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/"

java -jar /home/av795/bin/ASTRAL/Astral/astral.5.7.8.jar -i ${phylogeny}phy_output_psc100_supertree/ALL.trees -o out.tree 2>out.log
  
echo ""
echo "########### change group access"
chgrp -R g_geneva_1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/astral          


echo ""
echo "done"
  ```

</p>
</details>




## Visualizing species trees in R

[R Phylogenetic Trees](https://yulab-smu.top/treedata-book/chapter4.html)

- update R and RStudio
- packages needed
  - `tidyverse`
  - `ggtree`
    - To install this package (need updated version of R)
      ```
      if (!require("BiocManager", quietly = TRUE))
      install.packages("BiocManager")

      BiocManager::install("ggtree")
      ```
  - `treeio`
    - used to parse the tree file into R









