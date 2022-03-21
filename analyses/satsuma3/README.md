# Chromosome Synteny Analysis using Satsuma3

SatsumaSynteny2 is not working well with SLURM so we are trying SatsaumaSynteny version 3


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

_my genomes are too big to load in on my local machine so i am using R on amarel to load them in. I will then save an R data object and open this in R studio on my laptop_

1. Request an interactive node on amarel
```
srun --partition=p_ccib_1 --mem=150G --time=01:00:00 --pty bash
```
2. Load and launch R
```
module load R
R
```
3. Load in genomes
```
# load libraries

library(ape)

# load in grahami genome

wd <- "/projects/f_geneva_1/alyssa/grahami"
setwd(wd)
list.files()
grahami.genome = read.table(paste(wd,"AnoGra_wrapped.fa",sep="//"),sep = "\t")

# load in carolinensis genome

wd <- "/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3"
setwd(wd)
list.files()
carolinensis.genome<-read.table(paste(wd,"AnoCar2.0.fa",sep="//"),sep = "\t")

# load in satsuma summary file

wd <- "/projects/f_geneva_1/alyssa/grahami/satsuma/satsuma3/out_all"
setwd(wd)
list.files()

links<-read.table(paste(wd,"satsuma_summary.chained.out",sep = "//"))
links<-links[,1:6]
colnames(links)<-c("grahami","start_grahami","stop_grahami","carolinensis","start_carolinensis","stop_carolinensis")
links<-links[order(links$grahami,links$start_grahami),]
```
4. Save this as an R data object

[more info](https://rstudio-education.github.io/hopr/dataio.html#r-files)
```
save(grahami.genome,carolinensis.genome,links, file = "synteny.RData")
```
5. Save this file to Desktop using OnDemand
6. Open this file in RStudio
```
load("~/Desktop/synteny.RData")
```
7. manipulate `grahami.genome` file to be in the same format as `carolinensis.genome`










## to plot results
- `./MicroSyntenyPlot –i <satsuma_summary.txt>`
  - to create a postscript dot plot (color coded by target chromosomes).
- `./ChromosomePaint` 
  - to create a postscript file that colors chromosomes by color.
  - needs to be given a MizBee file
- `./BlockDisplaySatsuma` 
  - to create a file that can be shown in the interactive multi-level synteny browser

### `./ChromosomePaint`
- Comparative cromosome painter

Available arguments:
```
-i<string> : MizBee file
-o<string> : outfile (post-script)
-d<double> : dot size (def=1)
-s<double> : scale (def=60000)
-t<int> : target id (def=-1)
-d<bool> : print indivisual matchs (def=0)
-f<bool> : forward only (def=0)
```

My code:
```
time 
```

---

### `./MicroSyntenyPlot`
- Micro-synteny plotter

**Available arguments:**
```
-i<string> : HomologyByXCorr output file
-o<string> : outfile (post-script)
-d<double> : dot size (def=1)
-s<double> : scale (def=60000)
-t<int> : target id (def=-1)
-f<bool> : forward only (def=0)
```

**My code:**
```
time ${satsuma_folder}/MicroSyntenyPlot \
-i ${out_folder}/xcorr_aligns.final.all.out \
-o ${out_folder}/MicroSyntenyPlot
```

**output**
`MicroSyntenyPlot`

---

### `./BlockDisplaySatsuma`
- Takes a satsuma summary file and writes displayable blocks.

Available arguments:
```
-i<string> : satsuma summary file
-t<string> : target fasta file
-q<string> : query fasta file
-min<int> : minimum block size (def=3)
-s<int> : minimum scaffold size (def=100000)
-transpose<bool> : switch query and target (def=0)
```

**My code:**
```
time ${satsuma_folder}/BlockDisplaySatsuma \
-i ${out_folder}/satsuma_summary.chained.out \
-t ${work_folder}/AnoGra1.1.fa \
-q ${work_folder}/AnoCar2.0.fa
```

**output**
I think the output will be in the slurm output file











