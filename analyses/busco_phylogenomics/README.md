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
    <details><summary>code</summary>
    <p>
    
    ```
    cd
    conda install -c bioconda iqtree
    ```
    
    </p>
    </details>
- [x] `muscle`, `trimal`, and `iqtree` should be in `$PATH`

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
- we now have a shared lab folder to store previously ran busco results. this folder contains the zipped genome files and the busco results (path: `/projects/f_geneva_1/busco`).
- download genome sequence files from [NCBI](https://www.ncbi.nlm.nih.gov/genome) (or other places) in FASTA format (i searched for squamata in the NCBI search bar)
```
cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes

# with the update of the NCBI website, you can no longer do wget [link to genome download]

# find the genome you want to download and click on the link under the reference genome section

curl command

# unzip folder and genome will be the .fna file within ncbi_dataset/data/[GCA#######_specific to species]
```

## run BUSCO on all genomes

<details><summary>busco.sh</summary>
<p>
  
```
#!/bin/bash
#SBATCH --partition=main
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=busco
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/slurmout/slurm-%j-%x.out
#SBATCH --mem=160G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load conda environment"
eval "$(conda shell.bash hook)"
conda activate busco

echo "load variables"
FASTA=$1

echo "run busco"
busco -i /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/new/${FASTA} -c 16 -l vertebrata_odb10 -o ${FASTA} -m genome

echo "done"
```

<p>
</details>

then create a loop.sh to cycle through all the genome fasta files in a folder


<details><summary>run_busco.sh</summary>
<p>

```
#!/bin/bash
FILES=$(ls -1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/new/*.fa | cut -d "/" -f 10 | sort)
for FILE in $FILES
        do
	CMD="sbatch busco.sh ${FILE}"
        echo $CMD
        #eval $CMD
        sleep 0.25
done
```

<p>
</details>

to submit this job: `./run_busco.sh`

- In addition, move over BUSCO analysis ran on the final grahami assembly to this folder: `busco_out`

## Gzip files
- now all genome files can be gzipped

```
cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes

gzip *.fa
```

## Running busco_phylogenomics

1. activate conda busco environment or make new conda environment
   ```
   conda activate busco
   ```

2. move results from busco to new input directory
  - we need to extract the `run_vertebrata_odb10/` folder for each species and format it to `run_species/`

  
	<details><summary>move.sh</summary>
	<p>
	
	  ```
	  #!/bin/bash
	  #SBATCH --partition=p_ccib_1                    # which partition to run the job, options are in the Amarel guide
	  #SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
	  #SBATCH --job-name=move                     # job name for listing in queue
	  #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/slurmout/slurm-%j-%x.out
	  #SBATCH --mem=10G                              # memory to allocate in Mb
	  #SBATCH -n 1                                   # number of cores to use
	  #SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
	  #SBATCH --time=1-00:00:00                       # maximum run time days-hours:minutes:seconds
	  #SBATCH --requeue                               # restart and paused or superseeded jobs
	  #SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
	  #SBATCH --mail-type=FAIL
	  
	  
	  SPECIES=$1
	  
	  cp -R /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/busco_out/passing/${SPECIES}/run_vertebrata_odb10 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/phy_input/run_${SPECIES}
	  
	
	  ```
	
	</p>
	</details>

	<details><summary>run_move.sh</summary>
	<p>
	
	  ```
	  #!/bin/bash
	  FILES=$(ls -d -1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/busco_out/passing/*.fa | cut -d "/" -f 10 | sort)
	  for FILE in $FILES
	          do
	  	CMD="sbatch move.sh ${FILE}"
	          echo $CMD
	          eval $CMD
	          sleep 0.25
	  done
	  ```
	
	</p>
	</details>

3. run busco_phylogenomics on BUSCO results
- **Required Parameters**
  - `-d --directory`: input directory containing BUSCO runs
  - `-o --output`: output directory
  - `-t --threads`: number of threads to use
  - `--supermatrix` and/or `--supertree`: choose to run supermatrix and/or supertree methods
    - **IMPORTANT:** when running in `--supertree` mode, you need to hard-code the number of species you want the genes to be present and single copy in.
    - By default, the supertree methods choose BUSCOs that are present in 4 species
    - I copied the `BUSCO_Phylogenomics.py` to `BUSCO_Phylogenomics_supertree.py` and changed the minimum number to 75% of my species
      - I set mine to **64** out of the 86 species I am using in my tree
    - I also made a copy `BUSCO_Phylogenomics_supertree_psc100.py` where I set the number to **86** so i can see trees built on buscos present in all of my species 
- **Optional Parameters**
  - `-psc`: BUSCO families that are present and single-copy in N% of species will be included in supermatrix analysis (default = 100%). Families that are missing for a species will be replaced with missing characters ("?").
  - `--stop_early`: stop pipeline early before phylogenetic inference (i.e., for the supermatrix approach this will stop after generating the concatenated alignment). This is **recommended** so you can manually choose your own parameters (e.g., bootstrapping/model selection methods) or manually process/filter the alignments further when running IQ-Tree, etc..
  - Do **NOT** make the output directory before running the script. The script will make this directory, you just need to name it in the script.


	<details><summary>phy_sub.sh</summary>
	  <p>
	    
	   ```
    	#!/bin/bash
		#SBATCH --partition=p_geneva_1
		#SBATCH --exclude=halc068
		#SBATCH --job-name=buscophy_supertree_psc100
		#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/slurmout/slurm-%j-%x.out
		#SBATCH --mem=200G
		#SBATCH -n 20
		#SBATCH -N 1
		#SBATCH --time=7-00:00:00
		#SBATCH --requeue
		#SBATCH --mail-user=av795@rutgers.edu
		#SBATCH --mail-type=BEGIN,REQUEUE,FAIL,END
		
		
		echo "load modules"
		
		eval "$(conda shell.bash hook)"
		conda activate busco
		
		
		echo "run busco supermatrix"
		
		#python BUSCO_Phylogenomics.py -d phy_input -o phy_out_supermatrix_psc100 --supermatrix --threads 20
		#python BUSCO_Phylogenomics.py -d phy_input -o phy_out_supermatrix_psc75 --supermatrix --threads 20 -psc 75
		#python BUSCO_Phylogenomics.py -d phy_input -o phy_out_supermatrix_psc75_stopearly --supermatrix --threads 20 -psc 75 --stop_early
		
		echo "run busco supertree"
		
		python BUSCO_Phylogenomics_supertree_psc100.py -d phy_input -o phy_out_supertree_psc100 --supertree --threads 20
		#python BUSCO_Phylogenomics_supertree.py -d phy_input -o phy_out_supertree_psc75 --supertree --threads 20 -psc 75
		#python BUSCO_Phylogenomics_supertree.py -d phy_input -o phy_out_supertree_psc75_stopearly --supertree --threads 20 -psc 75 --stop_early
		
		echo "done"
		
		
		
		###### job names ######
		
		#buscophy_supermatrix_psc100
		#buscophy_supermatrix_psc75
		#buscophy_supermatrix_psc75_stopearly
		
		#buscophy_supertree_psc100
		#buscophy_supertree_psc75
	   ```
	    
	  </p>
	  </details>


## Output

### Supermatrix
- When submitting `phy_sub.sh` script, use `--supermatrix`
- Can visualize the completed tree by inputting the `.iqtree` file into FigTree or the `.treefile` file into [iTOL](https://itol.embl.de/)

### Supertree

1. When submitting `phy_sub.sh` script, use `--supertree`
2. Download ASTRAL
  - [ASTRAL github page](https://github.com/smirarab/ASTRAL)
  - [ASTRAL github tutorial page](https://github.com/smirarab/ASTRAL/blob/master/astral-tutorial.md)
  - I installed via git clone, then unzipped the jar file, moved all of astral download to bin
3. For astral help (display options)
   ```
   java -jar /home/av795/bin/ASTRAL/Astral/astral.5.7.8.jar
   ```

   **Path to my jar file**
   ```
   /home/av795/bin/ASTRAL/Astral/astral.5.7.8.jar
   ```

4. Make `astral.sh` to submit species tree analysis
- The input file will be the `ALL.trees` file from busco_phylogenomics
- Make the astral output directory before running
- **IMPORTANT:** you need to make the output directory before submitting the script.


<details><summary>astral.sh</summary>
<p>
  
  	```
	#!/bin/bash
	#SBATCH --partition=p_geneva_1
	#SBATCH --exclude=halc068
	#SBATCH --job-name=astral
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/astral/slurmout/slurm-%j-%x.out
	#SBATCH --mem=180G
	#SBATCH -n 20
	#SBATCH -N 1
	#SBATCH --time=4-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=BEGIN,REQUEUE,FAIL,END
	
	
	echo "########### load any modules needed"
	module purge
	module load java
	
	
	echo ""
	echo "load variables"
	
	phylogeny="/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics"
	INDIR="/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/phy_out_supertree_psc75"
	OUTDIR="/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/astral/run_supertree_psc75"
	
	
	echo ""
	echo "run astral"
	
	java -jar /home/av795/bin/ASTRAL/Astral/astral.5.7.8.jar -i ${INDIR}/ALL.trees -o ${OUTDIR}/out.tree 2>out.log
	
	
	echo ""
	echo "########### change group access"
	chgrp -R g_geneva_1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/astral
	
	
	echo ""
	echo "done"
  	```

</p>
</details>

## Renaming shortened names to full species names
- Now, we want to change the abbreviated species names out for the full species names
- We can run a quick command after the analyses are finished to rename the species to their full species name
- Most of the species (all the NCBI published genomes) have the full species name in the same format on the first line of the fasta file

	**make abbreviated names text file**
  	- I listed the genomes from our genome folder and then got rid of the `.gz`
  	- Alternatively, you could list the directory names in `phy_input` and then remove the `run_`
  	```
	ls -1 /projects/f_geneva_1/busco/genomes/*.gz | cut -d "/" -f 6  > abbr_names.txt
   	sed -i 's/.gz//g' abbr_names.txt 

   	# Then, I manually deleted the lines that I did not need
   	```

	<details><summary>run_rename.sh</summary>
	<p>

 	```
	#!/bin/bash
	SAMPLES=$(cut -f 1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/abbr_names.txt)
	for SAMPLE in $SAMPLES
	        do
		FULL=$(zcat /projects/f_geneva_1/busco/genomes/"${SAMPLE}".gz | head -n 1 | cut -d " " -f 2-3)
	        CMD="sed -i 's/${SAMPLE}/${FULL}/g' /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/old/phy_out_supermatrix_psc75/renamed_tree.aln"
	        echo $CMD
	        #eval $CMD
	        sleep 0.25
	done
  	```

   	</p>
	</details>

	<details><summary>manual renaming</summary>
	<p>

 	```
	sed -i 's/AnoApl1.1.fa/Anolis apletophallus/g'
	sed -i 's/AnoAur1.0.fa/Anolis auratus/g'
	sed -i 's/AnoFre1.0.fa/Anolis frenatus/g'
	sed -i 's/AnoGra1.1.fa/Anolis grahami/g'
	sed -i 's/AnoSag2.1.fa/Anolis sagrei/g'
	sed -i 's/BoaCon1.fa/Boa constrictor/g'
	sed -i 's/BraPum1.0.fa/Bradypodion pumilum/g'
	sed -i 's/BraVen1.1.fa/Bradypodion ventrale/g'
	sed -i 's/ShinCroc.fa/Shinisaurus crocodilurus/g'
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
  - `phangorn`
    - program densiTree

## DensiTree
- This program allows you to visualize all the gene trees stacked on top of one another
- This makes it easy to see where there is agreement and discordance among gene trees
- The darker the branches, the more gene trees support that relationship
- [**Website**](https://www.cs.auckland.ac.nz/~remco/DensiTree/)

### Installation
- Install the `.jar` file from GitHub
  ```
  cd
  wget https://github.com/rbouckaert/DensiTree/releases/download/v3.0.0/DensiTree.v3.0.2.jar
  mv DensiTree.v3.0.2.jar bin/
  ```
### Usage
- To run DensiTree, from the command line use java -jar DensiTree.jar from the directory where you saved the DensiTree jar file.
- DensiTree requires **java 8**
- [**Manual**](https://www.cs.auckland.ac.nz/~remco/DensiTree/DensiTreeManual.v2.2.pdf)

<details><summary>name</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_geneva_1
#SBATCH --exclude=halc068
#SBATCH --job-name=astral_psc100
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/astral/slurmout/slurm-%j-%x.out
#SBATCH --mem=180G
#SBATCH -n 20
#SBATCH -N 1
#SBATCH --time=14-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=REQUEUE,FAIL,END


echo "load any modules needed"
module purge
module load java/11.0.18

echo ""
echo "load variables"


echo ""
echo "run DensiTree"
java -Xmx3g -jar /home/av795/bin/DensiTree.v3.0.2.jar

echo ""
echo "done"
```

</p>
</details>











<details><summary>name</summary>
<p>

</p>
</details>



