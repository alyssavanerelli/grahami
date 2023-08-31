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
      - I set mine to **64** out of the 85 species I am using in my tree
    - I also made a copy `BUSCO_Phylogenomics_supertree_psc100.py` where I set the number to **85** so i can see trees built on buscos present in all of my species 
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

4. run `iqtree` if using the stop early flag
- stopping early allows you to customize the iqtree run
- this might be useful for setting the outgroup


<details><summary>iqtree.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=cmem
#SBATCH --exclude=memc001
#SBATCH --job-name=iqtree_psc75
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/slurmout/slurm-%j-%x.out
#SBATCH --mem=300G
#SBATCH -n 35
#SBATCH -N 1
#SBATCH --time=14-00:00:00
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load conda environment"
eval "$(conda shell.bash hook)"
conda activate iqtree


echo ""
echo "load variables"
INDIR="/projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/phy_out_supermatrix_psc75_all_stopearly"
PREFIX="run01"

cd ${INDIR}

echo ""
echo "run iqtree"
iqtree -s SUPERMATRIX.aln -bb 1000 -alrt 1000 -nt 35 -pre ${PREFIX} -o "SphenPunct1.fa" -mem 300G


#-nt AUTO -ntmax 35

echo ""
echo "done
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
- I made a tab-delimited text file with abbreviated names and full names using `grep`, `cat`, `sed`, and bbedit (i did quite a bit of this semi-manually).


<details><summary>full_names.txt</summary>
<p>

```
AhaPra1.0.fa    Ahaetulla prasina
AnnSte1.0.fa    Anniella stebbinsi
AnoCar2.0.fa    Anolis carolinensis
AriEle1.0.fa    Arizona elegans
AspMar1.0.fa    Aspidoscelis marmoratus
AspTig1.0.fa    Aspidoscelis tigris
AzeFeae1.0.fa   Azemiops feae
BothJara1.0.fa  Bothrops jararaca
BungMult1.0.fa  Bungarus multicinctus
CalypSin1.0.fa  Calyptommatus sinebrachiatus
ChaBot1.0.fa    Charina bottae
CrotAdam.fa     Crotalus adamanteus
CrotTig1.0.fa   Crotalus tigris
CrotVir3.0.fa   Crotalus viridis
CryEge1.0.fa    Cryptoblepharus egeriae
CteBak1.0.fa    Ctenosaura bakeri
DabSia1.0.fa    Daboia siamensis
DarVal1.0.fa    Darevskia valentini
DiaPun1.0.fa    Diadophis punctatus
ElgMul1.0.fa    Elgaria multicarinata
EubMac1.0.fa    Eublepharis macularius
EulEur1.0.fa    Euleptes europaea
FurPar1.0.fa    Furcifer pardalis
GekGec1.0.fa    Gekko gecko
GekJap1.1.fa    Gekko japonicus
HeloChar1.0.fa  Heloderma charlesbogerti
HemCap1.1.fa    Hemicordylus capensis
HydCur2.0.fa    Hydrophis curtus
HydCyan2.0.fa   Hydrophis cyanocinctus
HydMel1.0.fa    Hydrophis melanocephalus
IguDel1.0.fa    Iguana delicatissima
LacAgi1.0.fa    Lacerta agilis
LacBil.fa       Lacerta bilineata
LacVir1.fa      Lacerta viridis
LatCol2.0.fa    Laticauda colubrina
LatLat1.0.fa    Laticauda laticaudata
LepLis1.0.fa    Lepidodactylus listeri
MorVir1.0.fa    Morelia viridis
NajaNaja5.fa    Naja naja
NatHel1.0.fa    Natrix helvetica
NotScut2.0.fa   Notechis scutatus
OphHan1.0.fa    Ophiophagus hannah
PanAll1.0.fa    Pantherophis alleghaniensis
PanGut3.0.fa    Pantherophis guttatus
PanObs1.0.fa    Pantherophis obsoletus
ParPicta2.0.fa  Paroedura picta
PhrBla1.0.fa    Phrynosoma blainvillii
PhrFor1.0.fa    Phrynocephalus forsythii
PhrPlat1.1.fa   Phrynosoma platyrhinos
PhrVer1.0.fa    Phrynocephalus versicolor
PitCat1.0.fa    Pituophis catenifer
PleGil1.0.fa    Plestiodon gilberti
PodMur1.0.fa    Podarcis muralis
PodRaf1.0.fa    Podarcis raffonei
PogVit1.1.fa    Pogona vitticeps
ProtoFlav1.0.fa Protobothrops flavoviridis
ProtoMucro1.0.fa        Protobothrops mucrosquamatus
PsamPulv1.0.fa  Psammodynastes pulverulentus
PseudText2.0.fa Pseudonaja textilis
PtyMuc1.0.fa    Ptyas mucosa
PythBiv5.0.2.fa Python bivittatus
RhiFlo1.0.fa    Rhineura floridana
SalMer.fa       Salvator merianae
SceTri1.fa      Sceloporus tristichus
SceUnd1.1.fa    Sceloporus undulatus
SphenPunct1.fa  Sphenodon punctatus
SphTown2.3.fa   Sphaerodactylus townsendi
ThaEle1.pri.fa  Thamnophis elegans
TherBail1.0.fa  Thermophis baileyi
TretOrix1.0.fa  Tretioscincus oriximinensis
VarKomo1.fa     Varanus komodoensis
VarSal1.0.fa    Varanus salvator
VipBer1.0.fa    Vipera berus
VipLat1.0.fa    Vipera latastei
VipUrs1.1.fa    Vipera ursinii
ZooViv1.fa      Zootoca vivipara
AnoApl1.1.fa    Anolis apletophallus
AnoAur1.0.fa    Anolis auratus
AnoFre1.0.fa    Anolis frenatus
AnoGra1.1.fa    Anolis grahami
AnoSag2.1.fa    Anolis sagrei
BoaCon1.fa      Boa constrictor
BraPum1.0.fa    Bradypodion pumilum
BraVen1.1.fa    Bradypodion ventrale
ShinCroc.fa     Shinisaurus crocodilurus
AchJin1.0.fa    Achalinus jinggangensis
AnoAlli1.0.fa   Anolis allisoni
AnoAllo1.0.fa   Anolis allogus
AnoHomo1.0.fa   Anolis homolechis
AnoIso1.0.fa    Anolis isolepis
AnoPor1.0.fa    Anolis porcatus
ArgDia1.0.fa    Argyrophis diardii
BoaeFul1.0.fa   Boaedon fuliginosus
CalaSept1.0.fa  Calamaria septentrionalis
CalVers2.0.fa   Calotes versicolor
CrotOre1.0.fa   Crotalus oreganus
CycPin1.0.fa    Cyclura pinguis
CylRuf1.0.fa    Cylindrophis ruffus
DeinAcut1.0.fa  Deinagkistrodon acutus
EreArg1.0.fa    Eremias argus
EryxTat1.0.fa   Eryx tataricus
EupPer1.0.fa    Euprepiophis perlacea
GloyShed1.0.fa  Gloydius shedaoensis
HeloSusp1.0.fa  Heloderma suspectum
HypPlu1.0.fa    Hypsiscopus plumbea
IntLes1.0.fa    Intellagama lesueurii
LaudSac1.0.fa   Laudakia sacra
LepNig1.0.fa    Leptotyphlops nigroterminus
LerEdw1.0.fa    Lerista edwardsae
NatNat1.0.fa    Natrix natrix
OphGra1.0.fa    Ophisaurus gracilis
PareBerd1.0.fa  Pareas berdmorei
PhrPrz1.0.fa    Phrynocephalus przewalskii
PhrVla1.0.fa    Phrynocephalus vlangalii
PodCret1.0.fa   Podarcis cretensis
UtaStan1.0.fa   Uta stansburiana
XenoUni1.0.fa   Xenopeltis unicolor
```

</p>
</details>


<details><summary>run_fullname.sh</summary>
<p>

```
#!/bin/bash
SAMPLES=$(cut -f 1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/full_names.txt)
for SAMPLE in $SAMPLES
        do 
        ABBR=${SAMPLE}
        FULL=$(grep ${SAMPLE} /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/full_names.txt | cut -f 2)
        CMD="sed -i 's/${ABBR}/${FULL}/g' /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/phy_out_supermatrix_psc100_all/psc100_all_renamed.tre"
        echo $CMD
        eval $CMD
        sleep 0.25
done
```

</p>
</details>

---

## Visualizing species trees in R
- Resources
  - [R Phylogenetic Trees](https://yulab-smu.top/treedata-book/chapter4.html)
  - [Visulaizing and annotating trees in ggtree](https://4va.github.io/biodatasci/r-ggtree.html)
  - [Visualization and annotation of phylogenetic trees: ggtree](https://guangchuangyu.github.io/ggtree-book/chapter-ggtree.html)

### Prepare tree file
- Download the Newick tree from amarel onto your desktop (running this locally because you can't install ggtree on the amarel version of R)
- Open tree in FigTree and **reroot** with outgroup. Then export this tree as shown to a new `.tre` file

### ggtree in R

<details><summary>ggtree.R</summary>
<p>

```

```

</p>
</details>

---

## DensiTree
- This program allows you to visualize all the gene trees stacked on top of one another
- This makes it easy to see where there is agreement and discordance among gene trees
- The darker the branches, the more gene trees support that relationship
- We will be using densiTree in R with the `phangorn` package
- [**densiTree documentation**](https://search.r-project.org/CRAN/refmans/phangorn/html/densiTree.html)
- I had to do this locally because I couldn't install `phangorn` on the version of R used by amarel

<details><summary>densitree.R</summary>
<p>

```
# load libraries
library(phangorn)
library(ape)


# read in data
filename <- "~/Desktop/psc75.trees"
psc75.phy <- ape::read.tree(filename); phytools::read.newick(filename)

# run densiTree
densiTree(psc75.phy, type = "cladogram", direction = "rightwards", width = 1, lty = 1, cex = 0.8, font = 3)
```

</p>
</details>





--- 

<details><summary>name</summary>
<p>

</p>
</details>



