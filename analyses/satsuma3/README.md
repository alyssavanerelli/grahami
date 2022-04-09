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










<details><summary>name</summary>
<p>

</p>
</details>
