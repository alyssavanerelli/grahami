# Satsuma2 for Chromosome Synteny Analysis

[github page](https://github.com/bioinfologics/satsuma2)

**Main Objectives**
1. homology of known anole chromosomes
   - chromosomes 1-4 are homologous across _sagrei_ and _carolinensis_
2. look for evidence of fusion/fission in the genome

**We are using _Anolis carolinensis_ for this because they have done analyses to confirm chromosomes**


## Installation
1. Create a new [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html) environment for satsuma
    ```
    conda create satsuma
    
    conda activate satsuma
    ```
2. [Install](https://anaconda.org/bioconda/satsuma2) satsuma using conda 
    ```
    conda install -c bioconda satsuma2
    ```
## Running Satsuma2

### Set Up

1. Activate satsuma conda environment
   ```
   conda activate satsuma
   ```
2. Need to set an environment variable to tell software where to find the binaries (because Satsuma2 calls other executables)
   ```
   export SATSUMA2_PATH=/home/av795/.conda/envs/satsuma/bin
   ```
   _not sure whether to run this on command line or add to job script_
  
3. Satsuma generic code
   ```
   ./SatsumaSynteny2 -q query.fa -t target.fa -o output_dir
   ```
   **Required parameters**
    - `-q<string>`: query fasta sequence
    - `-t<string>`: targer fasta sequence
    - `-o<string>`: output directory
   
   **Optional parameters**   
    - `-l<int>`: minimum alignment length (def=0)
    - `-t_chunk<int>`: target chunk size (def=4096)
    - `-q_chunk<int>`: query chunk size (def=4096)
    - `-sl_mem<int>`: memory requirement for slaves (Gb) (def=100)
    - `-do_refine<bool>`: refinement steps (def=0)
    - `-min_prob<double>`: minimum probability to keep match (def=0.99999)
    - `-cutoff<double>`: signal cutoff (def=1.8)
    - `-prob_table<bool>`: approximate match prob using a table lookup in slaves (def=0)
    - `min_matches<int>`: minimum matches per target to keep iterating (def=20)
    - `-m<int>`: number of jobs per block (def=4)
    - `-slaves<int>`: number of processing slaves (def=1)
    - `-threads<int>`: number of working threads per processing slave (def=1)
    - `-km_mem<int>`: memory required for kmatch (Gb) (def=100)
    - `-km_sync<bool>`: run kmatch jobs synchronously (def=1)
    - `-seed<string>`: loads seeds and runs from there (kmatch files prefix) (def=)
    - `-min_seed_length<int>`: minimum length for kmatch seeds (after collapsing) (def=24)
    - `-max_seed_kmer_freq<int>`: maximum frequency for kmatch seed kmers (def=1)
    - `-old_seed<string>`: loads seeds and runs from there (xcorr*data) (def=)
    - `-pixel<int>`: number of blocks per pixel (def=24)
    - `-nofilter<bool>`: do not pre-filter seeds (slower runtime) (def=0)
    - `-dups<bool>`: allow for duplications in the query sequence (def=0)
    - `-dump_cycle_matches<bool>`: dump matches on each cycle (for debug/testing) (def=0)


   **More Info**
   
   <details><summary>expand</summary>
   <p>
   
    - The query and target sequences are chunked (based on the -t_chunk and -q_chunk parameters) then KMatch is used to detect aligning regions between chunks.
    - The number of chunks generated depends on the length of your query and target sequences. The amount of memory reserved for KMatch can be modified using the -km_mem parameter which defaults to 100Gb.
    - The number of slaves, threads per slave and memory limit per slave are specified using the -slaves, -threads and -sl_mem parameters.
    - The default is to run one single-threaded slave using 100Gb of memory. 
    - The satsuma_run.sh file is used by SatsumaSynteny2 to start the slaves. 
    - Before running SatsumaSynteny2, you need to modify this file to suit your HPC environment by commenting out the lines you don't need with #. Y
    - You will also need to change 'QueueName' to a queue that exists on your system.
    - If SatsumaSynteny2 is run without a submission system, KMatch jobs will be launched synchronously in order to keep memory requirements low. If you have plenty of memory available you can opt to run the KMatch jobs asynchronously (-km_sync 0). KMatch requires a lot of memory and multiple KMatch processes running at the same time may cause SatsumaSynteny2 to abort if not enough memory is available.
    - The parameters `-km_mem` and `-sl_mem` are only applied when using a job submission system. We strongly recommend using a job submission system to run SatsumaSynteny2 which allows more control of the resource requirements of this software.
    - If the output directory is not empty, SatsumaSynteny2 will not overwrite any files but exit with an error message.
    - Idling processes self-terminate after two minutes. The overall alignments will still complete, but using fewer processes.
    - Currently, the entire sequences are loaded into RAM by each process. For comparison of large genomes, we strongly recommend to make sure that the CPUs have enough RAM available (~ the size of both genomes in bytes).

</p>
</details>

   **Tips**

<details><summary>expand</summary>
<p>

   - The default parameters should work well for most genomes.
   - SatsumaSynteny2 runs most efficiently on either multi-processor machines or on clusters that are tightly coupled (fast access to files shared by the control process and the slaves)
   - Especially for larger genomes, we recommend leaving one CPU dedicated to the control process SatsumaSynteny2.
   - For larger genomes (>1Gb), we recommend using one chromosome of one genome as the query sequence and the entire other genome as the target sequence, and process alignments one query chromosome at a time.
   - To include large-scale duplications in the query sequence (in addition to the target sequence), use the option –dups.
   - If using the option –nofilter, the number of initial searches (-ni) should be higher than the number of processes (-n) to ensure that subsequent processes have sufficient seeds. Note that initial searches will be queued to a number of processes specified by -n.
   - When many processes search a tight space, the number of pixels per CPU (-m) should be small (e.g. ‘–m 1’ as in the sample script/data set) to avoid unbalanced load (i.e. some processes get all the pixels while others are starved, since they overlap). However, a small value for –m increases inter-process communication, which should be a consideration when deploying hundreds of processes.

</p>
</details>



### Ready to Run

1. Make `satsuma_run.sh` for SLURM

      ```
     #!/bin/bash

     # Script for starting Satsuma jobs on different job submission environments
     # One section only should be active, ie. not commented out
   
     # Usage: satsuma_run.sh <current_path> <kmatch_cmd> <ncpus> <mem> <job_id> <run_synchronously>
     # mem should be in Gb, ie. 100Gb = 100
     
     # no submission system, processes are run locally either synchronously or asynchronously
     #if [ "$6" -eq 1 ]; then
     #  eval "$2"
     #else
     #  eval "$2" &
     #fi
     
     ##############################################################################################################
     ## For the sections below you will need to change the queue name (QueueName) to one existing on your system ##
     ##############################################################################################################
  
     # qsub (PBS systems)
     #echo "cd $1; $2" | qsub -V -qQueueName -l ncpus=$3,mem=$4G -N $5
     
     # bsub (LSF systems)
     #mem=`expr $4 + 1000`
     #bsub -o ${5}.log -J $5 -n $3 -q QueueName -R "rusage[mem=$mem]" "$2"
     
     # SLURM systems
     echo "#!/bin/bash" > slurm_tmp.sh
     echo srun $2 >> slurm_tmp.sh
     sbatch -p p_ccib_1 --exclude=gpuc001,gpuc002 --time=0-06:00:00 -c $3 -J $5 -o ${5}.log --mem ${4}G slurm_tmp.sh
     ```

2. Move this file to binaries folder (for satsuma) and make executable

     ```
     mv satsuma_run.sh /home/av795/.conda/envs/satsuma/bin
     
     chmod 755 /home/av795/.conda/envs/satsuma/bin/satsuma_run.sh
     ```


3. Split _grahami_ genome into largest scaffolds

   - Since our genomes are >1 Gb (1.4G and 1.8G), we need to use the entire _sagrei_ genome as the target sequence and one chromosome from _grahami_ as the query sequence.
   - Will split genome into separate files for scaffolds 1-6 (since they are so large)
   - Make a file containing scaffolds 7-15,847

<details><summary>code not used</summary>
<p>

**copy chrom sizes over**
```
cd /projects/f_geneva_1/alyssa/grahami/satsuma
cp ../juicerdir/AnoGra/references/AnoGra1.1.chrom.sizes .
```

**keep only 17 largest scaffolds**
```
sed '18, $ d' AnoGra1.1.chrom.sizes > AnoGra_lgsc.fa
```

</p>
</details>

**split genome: scaffolds 1-6**
 - do this six times, one time for each scaffold

```
grep -w scaffold_9 -A 1 AnoGra1.1.fa > sc9.fa
```

**check that only that scaffold is there**
```
grep ">" sc9.fa                  #should return only ">scaffold_9"

less sc9.fa                      #make sure that ">scaffold_9" and sequence are in the file
```

**split genome: scaffolds 7-15,847**
```
tail -n +13 AnoGra1.1.fa > sc7_end.fa
```


4. Run Satsuma
  
  - To run SatsumaSynteny2, you need to paste these lines into the command line (not sbatch a script)
  - SatsumaSynteny2 will then use the `satsuma_run.sh` file created above to submit slurm jobs
  - Will need to submit this job script **7 times**
    - one time for each large scaffold (1-6)
    - one time for the file of scaffolds 7-15,847

    ```
    export SATSUMA2_PATH=/home/av795/.conda/envs/satsuma/bin
   
    module use /projects/community/modulefiles/
    module load gcc/7.3.0-gc563
   
    cd /projects/f_geneva_1/alyssa/grahami/satsuma
   
    /home/av795/.conda/envs/satsuma/bin/SatsumaSynteny2 \
     -t /projects/f_geneva_1/alyssa/grahami/satsuma/AnoCar2.0.fa \
     -q /projects/f_geneva_1/alyssa/grahami/satsuma/sc1.fa \
     -o /projects/f_geneva_1/alyssa/grahami/satsuma/out \
     -slaves 4 \
     -threads 4 
    ```

- the query sequence: _grahami_ chromosome
- the target sequence: _carolinensis_ genome


## Output






   
