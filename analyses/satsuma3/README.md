# Chromosome Synteny Analysis using Satsuma3

SatsumaSynteny2 is not working well with SLURM so we are trying SatsaumaSynteny version 3

**Main Objectives**
1. homology of known anole chromosomes
   - chromosomes 1-4 are homologous across _sagrei_ and _carolinensis_
2. look for evidence of fusion/fission in the genome

**We are using _Anolis carolinensis_ for this because they have done analyses to confirm chromosomes**

# Resources
- [Satsuma](http://satsuma.sourceforge.net/)
- [Manual](http://satsuma.sourceforge.net/manual.html)

<details><summary>code from pietro</summary>
<p>
  
  ```
  #!/bin/bash
#SBATCH --job-name=Satsuma_sagrei_carolinensis
#SBATCH --partition=glor,kbs,bi,eeb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=20-00:00:00
#SBATCH --mem=500G
#SBATCH --mail-user=hollandademello@ku.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/panfs/pfs.local/scratch/glor/p470d241/Satsuma_sagrei_carolinensis_%j.log

# Here I will make a synteny plot between the A sagrei genome and the A carolinensis
# genome.

work_folder=/panfs/pfs.local/work/glor/p470d241/sagrei_synteny
out_folder=/panfs/pfs.local/scratch/glor/p470d241/sagrei_synteny
carolinensis_folder=/panfs/pfs.local/work/glor/p470d241/carolinensis_fasta
satsuma_folder=/panfs/pfs.local/work/glor/p470d241/Programs/satsuma-code-0

mkdir -p $out_folder/Satsuma
zcat $work_folder/AnoSag2.1.fa.gz > $out_folder/A_sagrei.fa
zcat $carolinensis_folder/Anolis_carolinensis.AnoCar2.0.dna.toplevel.fa.gz > $out_folder/A_carolinensis.fa

export PATH=/panfs/pfs.local/work/glor/p470d241/Programs/satsuma-code-0:$PATH

time $satsuma_folder/SatsumaSynteny \
-t $out_folder/A_sagrei.fa \
-q $out_folder/A_carolinensis.fa \
-o $out_folder/Satsuma/Satsuma_sagrei_carolinensis -n 24
  ```

</p>
</details>


# Installation
- Will install using source code

1. Follow link to source code
2. clone environment using link
   ```
   git clone https://git.code.sf.net/p/satsuma/code satsuma-code
   ```
3. compile
   ```
   cd satsuma-code
   make
   ```



# Set up 
- set up the `satsuma.sh` run file that will submit the job

<details><summary>satsuma.sh</summary>
<p>
  
  ```
  #!/bin/bash


#SBATCH --partition=p_ccib_1   
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002         
#SBATCH --job-name=satsuma                  
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/slurmout/slurm-%j-%x.out
#SBATCH --mem=700G                              
#SBATCH --cpus-per-task=50                                
#SBATCH --ntasks=1              
#SBATCH --time=14-00:00:00
#SBATCH --no-requeue                       
#SBATCH --mail-user=av795@rutgers.edu     
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE	
  
work_folder=/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3
out_folder=/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/out
satsuma_folder=/home/av795/bin/satsuma-code


export PATH=/home/av795/bin/satsuma-code:$PATH

time ${satsuma_folder}/SatsumaSynteny \
-t ${work_folder}/sc6.fa \
-q ${work_folder}/AnoCar2.0.fa \
-o ${out_folder} -n 50
    
  ```

</p>
</details>


<details><summary>notes</summary>
<p>
  
  ```
  If the output directory is not empty, SatsumaSynteny will not overwrite any files but exit with an error message.

Idling processes self-terminate after two minutes. The overall alignments will still complete, but using fewer processes.

If alignment runs locally but not on the server farm, check whether processes on the farm can communicate via TCP/IP.

Currently, the entire sequences are loaded into RAM by each process. For comparison of large genomes, we strongly recommend to make sure that the CPUs have enough RAM available (~ the size of both genomes in bytes).


Parameter choice, execution and data preparation
The default parameters should work well for most genomes.

SatsumaSynteny runs most efficiently on either multi-processor machines or on clusters that are tightly coupled (fast access to files shared by the control process and the slaves)

Especially for larger genomes, we recommend leaving one CPU dedicated to the control process SatsumaSynteny.

For larger genomes (>1.5 Gb), we recommend using one chromosome of one genome as the target sequence and the entire other genome as the query sequence, and process alignments one query chromosome at a time. We tested this strategy successfully on a mammalian genome pair.

To include large-scale duplications in the query sequence (in addition to the target sequence), use the option –dups.

If using the option –nofilter, the number of initial searches (-ni) should be higher than the number of processes (-n) to ensure that subsequent processes have sufficient seeds. Note that initial searches will be queued to a number of processes specified by -n.

When many processes search a tight space, the number of pixels per CPU (-m) should be small (e.g. ‘–m 1’ as in the sample script/data set) to avoid unbalanced load (i.e. some processes get all the pixels while others are starved, since they overlap). However, a small value for –m increases inter-process communication, which should be a consideration when deploying hundreds of processes.
  ```

</p>
</details>

# Run syteny for _sagrei_ and _carolinensis_
- I ran _grahami_ and _carolinensis_ in one run 
- To run _grahami_ and _sagrei_, I split _grahami_ into separate scaffolds and submitted them separately
  - Then combined output files
    ```
    # combine files
    cat sc1/satsuma_summary.chained.out sc2/satsuma_summary.chained.out sc3/satsuma_summary.chained.out sc4/satsuma_summary.chained.out sc5/satsuma_summary.chained.out sc6/satsuma_summary.chained.out sc7-end/satsuma_summary.chained.out > satsuma_summary_all.chained.out
    ```

<details><summary>split genome into scaffolds</summary>
<p>

**split genome: scaffolds 1-6**
 - do this six times, one time for each scaffold

```
grep -w scaffold_1 -A 1 AnoGra1.1.fa > sc1.fa
```

**check that only that scaffold is there**
```
grep ">" sc1.fa                  #should return only ">scaffold_1"

less sc1.fa                      #make sure that ">scaffold_1" and sequence are in the file
```

**split genome: scaffolds 7-15,847**
```
tail -n +13 AnoGra1.1.fa > sc7_end.fa
```

**split genome: scaffolds 7-100*
```
head -188 sc7_end.fa > sc7-sc100.fa
```
  
</p>
</details>


# Output
- `satsuma_summary.out`: readable alignments (Satsuma only)
- `satsuma_summary.refined.out`: final readable alignments (Satsuma and SatsumaSynteny)

format:
```
Contents:
Target sequence name (provided by fasta)
First target base
Last target base
Query sequence name (provided by fasta)
First query base
Last query base
Identity
Orientation

EXAMPLE:

chrX 5947 6164 chrX 9153 9360 0.626728 +
chrX 6270 6452 chrX 9472 9654 0.576923 +
```

## Visualize results in R
- I am using code from Pietro
- This code will make a circos plot to view _carolinensis_ and _grahami_ syteny
- Also will do this to visualize synteny between _grahami_ and _sagrei_

- I am doing this using the interactive RStudio available via OnDemand

First we need to make a file containing the scaffold name and size for each species
- _grahami_: done during pilon and copied over
- _carolinensis_:
  - need to change the formatting of the header to match the satsuma synteny output
  ```
  # remove spaces from header
  cp AnoCar2.0.fa AnoCar_t.fa
  sed -i 's/ /_/g' AnoCar_t.fa 
  
  # index and create file of sizes
  samtools faidx /projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/AnoCar_t.fa
  cut -f1-2 /projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/AnoCar_t.fa.fai > AnoCar2.0.chrom.sizes
  ```

- _sagrei_:
  ```
  samtools faidx /projects/f_geneva_1/alyssa/grahami/AnoSag2.1.fa
  cut -f1-2 /projects/f_geneva_1/alyssa/grahami/AnoSag2.1.fa.fai > AnoSag2.1.chrom.sizes
  ```
  - also need to rename scaffolds in `AnoSag2.1.chrom.sizes` and the satsuma_synteny file so they do not have the same name as grahami scaffolds
    ```
    # change name in sizes file - in bash
    sed -i 's/scaffold/sag_scaffold/g' AnoSag2.1.chrom.sizes
    
    # change names of sagrei scaffolds in summary file - in R
    > 
    ```

<details><summary>car_gra_synteny.R</summary>
<p>

</p>
</details>


<details><summary>sag_gra_synteny.R</summary>
<p>

</p>
</details>


## Visualize sex chromosome synteny
[github page](https://github.com/schneebergerlab/plotsr)

- sex chrom for grahami: 11 and 12
- sex chrom for sagrei: 7
- sex chrom for carolinensis: LgB

- We want to visualize the where the grahami sex chromsomes map to within sagrei and carolinensis
- For this we are using the python tool `plotsr`

**1. Install Plotsr**

```
conda activate satsuma

conda install -c bioconda plotsr

conda update -n base -c defaults conda          #update conda if needed

plotsr -h                                       #check that plotsr installed properly
```

**2. Gather Materials**
- [x] Chromosome-level assemblies for the genomes to be compared
- [x] Pairwise structural annotations between genomes
   - this is needed for each connection (grahami-sagrei and grahami-carolinensis)

| File Names                    | File description |
| ----------------------------- | ---------------- |
| `.fa`                         | fasta file       |
| `satsuma_summary.chained.out` | Pairwise structural annotation information between genomes |
| `genomes.txt`                 | file containing genome information |
| `base.cfg`                    | Configuration file for adjusting visual properties of the plot |


**3. Align all the genomes**
- align using [minimap](https://github.com/lh3/minimap2) and index with samtools
- align sagrei to grahami and grahami to carolinensis
- `minimap2` is an amarel module that can be loaded with `module load Minimap2/minimap2-2.14`


align and index
```
# Align genomes
minimap2 -ax asm5 -t 4 --eqx A.fa B.fa \
 | samtools sort -O BAM - > A_B.bam
samtools index A_B.bam
minimap2 -ax asm5 -t 4 --eqx B.fa C.fa \
 | samtools sort -O BAM - > B_C.bam
samtools index B_C.bam
```

<details><summary>AlignIndex.sh</summary>
<p>
   
   ```
   #!/bin/bash
   #SBATCH --partition=p_ccib_1
   #SBATCH --account=general
   #SBATCH --exclude=gpuc001,gpuc002
   #SBATCH --job-name=minimap
   #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/plotsr/slurmout/slurm-%j-%x.out
   #SBATCH --mem=170G
   #SBATCH -n 10
   #SBATCH -N 1
   #SBATCH --time=14-00:00:00
   #SBATCH --requeue
   #SBATCH --mail-user=av795@rutgers.edu
   #SBATCH --mail-type=FAIL,END,BEGIN.REQUEUE

   echo "load modules"
   module purge

   eval "$(conda shell.bash hook)"
   conda activate satsuma

   module load Minimap2/minimap2-2.14
   module samtools

   echo ""
   echo "check modules loaded"
   ml

   echo ""
   echo "set variables"
   OUTDIR="/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/plotsr"
   INPUTDIR="/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3"
   GRAHAMI="/projects/f_geneva_1/alyssa/grahami"

   echo ""
   echo "run minimap2 and samtools"

   minimap2 -ax asm5 -t 4 --eqx ${GRAHAMI}/AnoSag2.1.fa ${INPUTDIR}/AnoGra1.1.fa \
    | samtools sort -O BAM - > ${OUTDIR}/sagrei_grahami.bam
   samtools index sagrei_grahami.bam
   minimap2 -ax asm5 -t 4 --eqx ${INPUTDIR}/AnoGra1.1.fa ${INPUTDIR}/AnoCar2.0.fa \
    | samtools sort -O BAM - > ${OUTDIR}/grahami_carolinensis.bam
   samtools index grahami_carolinensis.bam

   echo ""
   echo "done"
   ```

</p>
</details>




**4. Finding structural annotations between genomes**
- Find synteny and rearrangements between genomes
- needs to be in BEDPE format
   ```
   Reference chromosome name
   Reference start position
   Reference end position
   Query chromosome name
   Query start position
   Query end position
   Annotation type
   ```
   
   valid annotations:
   ```
   SYN	Syntenic
   INV	Inversion
   TRA	Translocation
   INVTR	Inverted translocation
   DUP	Duplication
   INVDP	Inverted duplication
   ```
- the satsuma output has everything except annotation type so we may not be able to use this file 
- can generate this file using [SyRI](https://github.com/schneebergerlab/syri)

```
# Running syri for finding structural rearrangements between A and B
syri -c A_B.bam -r A.fa -q B.fa -F B --prefix A_B &
# Running syri for finding structural rearrangements between B and C
syri -c B_C.bam -r B.fa -q C.fa -F B --prefix B_C &
# Running syri for finding structural rearrangements between C and D
syri -c C_D.bam -r C.fa -q D.fa -F B --prefix C_D &
```

This will generate A_Bsyri.out, B_Csyri.out, and C_Dsyri.out files that contain the structural annotations between genomes and will be used as input to plotsr.

<details><summary>SyRI.sh</summary>
<p>
   
   ```
   #!/bin/bash
   #SBATCH --partition=p_ccib_1
   #SBATCH --account=general
   #SBATCH --exclude=gpuc001,gpuc002
   #SBATCH --job-name=SyRI
   #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/plotsr/slurmout/slurm-%j-%x.out
   #SBATCH --mem=170G
   #SBATCH -n 10
   #SBATCH -N 1
   #SBATCH --time=14-00:00:00
   #SBATCH --requeue
   #SBATCH --mail-user=av795@rutgers.edu
   #SBATCH --mail-type=FAIL,END,BEGIN.REQUEUE

   echo "###################### load modules"
   module purge

   eval "$(conda shell.bash hook)"
   conda activate satsuma


   echo ""
   echo "###################### check modules loaded"
   ml

   echo ""
   echo "set variables"
   OUTDIR="/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/plotsr"
   INPUTDIR="/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3"
   GRAHAMI="/projects/f_geneva_1/alyssa/grahami"

   echo ""
   echo "###################### run SyRI"

   echo "# Running syri for finding structural rearrangements between A and B"
   syri -c ${OUTDIR}/sagrei_grahami.bam -r ${GRAHAMI}/AnoSag2.1.fa -q ${INPUTDIR}/AnoGra1.1.fa -F B --prefix sagrei_grahami &

   echo "# Running syri for finding structural rearrangements between B and C"
   syri -c ${OUTDIR}/grahami_carolinensis.bam -r ${INPUTDIR}/AnoGra1.1.fa -q ${INPUTDIR}/AnoCar2.0.fa -F B --prefix grahami_carolinensis &

   echo ""
   echo "###################### done"
   ```

</p>
</details>


**5. Make config file**

<details><summary>base.cfg</summary>
<p>
   
   ```
   ## COLOURS and transparency for alignments (syntenic, inverted, translocated, and duplicated)
   syncol:#CCCCCC
   invcol:#FFA500
   tracol:#9ACD32
   dupcol:#00BBFF
   alpha:0.8

   ## Margins and dimensions:
   chrmar:0.1              ## Adjusts the gap between chromosomes and tracks. Higher values leads to more gap
   exmar:0.1               ## Extra margin at the top and bottom of plot area

   ## LEGEND
   legend:T                ## To plot legend use T, use F to not plot legend
   genlegcol:-1            ## Number of columns for genome legend, set -1 for automatic setup
   bbox:0,1.01,0.5,0.3		## [Left edge, bottom edge, width, height]
   bbox_v:0,1.1,0.5,0.3	## For vertical chromosomes (using -v option)
   bboxmar:0.5             ## Margin between genome and annotation legends
   ```

</p>
</details>

**6. Running plotsr**
- make genome file and run plotsr


**make `genomes.txt`**
- this is a tab-separated file containing the path and names for the genomes. 
- A third column can also be added to customise the visualisation of genomes.
   - tags available
   ```
   ft = File type (fa/cl for fasta/chromosome_length, default = fa); cl files must be in tsv format with chromosome name in column 1 and chromosome length in column 2; using cl files is much faster than using fasta files
   lw = line width
   lc = line colour
   ```

example file
```
$genomes.txt
#file	name	tags
A.fa	A	lw:1.5
B.fa	B	lw:1.5
C.fa	C	lw:1.5
D.fa	D	lw:1.5
```

_**NOTE:** It is required that the order of the genomes is the same as the order in which genomes are compared. For example, if the first genome annotation file uses A as a reference and B as query, and the second genome annotation file uses B as a reference and C as query, then the genomes.txt file should list the genomes in the order A, B, C._

<details><summary>genomes.txt</summary>
<p>
   
   ```
   #file   name    tags
   /projects/f_geneva_1/alyssa/grahami/AnoSag2.1.fa        A	lw:1.5
   /projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/AnoGra1.1.fa	B	lw:1.5
   /projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/AnoCar2.0.fa	C	lw:1.5
   ```

</p>
</details>

**run plotsr**

```
plotsr \
    --sr A_Bsyri.out \
    --sr B_Csyri.out \
    --sr C_Dsyri.out \
    --genomes genomes.txt \
    -o output_plot.png
```

<details><summary>plotsr.sh</summary>
<p>
   
   ```
   #!/bin/bash
   #SBATCH --partition=p_ccib_1
   #SBATCH --account=general
   #SBATCH --exclude=gpuc001,gpuc002
   #SBATCH --job-name=plotsr
   #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/plotsr/slurmout/slurm-%j-%x.out
   #SBATCH --mem=170G
   #SBATCH -n 10
   #SBATCH -N 1
   #SBATCH --time=14-00:00:00
   #SBATCH --requeue
   #SBATCH --mail-user=av795@rutgers.edu
   #SBATCH --mail-type=FAIL,END,BEGIN.REQUEUE

   echo "###################### load modules"
   module purge

   eval "$(conda shell.bash hook)"
   conda activate satsuma


   echo ""
   echo "set variables"
   OUTDIR="/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/plotsr"
   INPUTDIR="/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3"
   GRAHAMI="/projects/f_geneva_1/alyssa/grahami"

   echo ""
   echo "###################### run plotsr"
   plotsr \
       --sr ${OUTDIR}/sagrei_grahamisyri.out \
       --sr ${OUTDIR}/grahami_carolinensissyri.out \
       --genomes genomes.txt \
       -o output_plot.png

   echo ""
   echo "###################### done"
   ```

</p>
</details>









<details><summary>name</summary>
<p>

</p>
</details>
