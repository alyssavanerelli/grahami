# Satsuma2 for Chromosome Synteny Analysis

[github page](https://github.com/bioinfologics/satsuma2)

**Main Objectives**
1. homology of known anole chromosomes
   - chromosomes 1-4 are homologous across _sagrei_ and _carolinensis_
2. look for evidence of fusion/fission in the genome


## Installation
1. Create a new [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html) environment for satsuma ??
    ```
    conda create satsuma
    
    conda activate satsuma
    ```
2. [Install](https://anaconda.org/bioconda/satsuma2) satsuma using conda 
    ```
    conda install -c bioconda satsuma2
    ```
## Running Satsuma2

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
    - The query and target sequences are chunked (based on the -t_chunk and -q_chunk parameters) then KMatch is used to detect aligning regions between chunks.
    - The number of chunks generated depends on the length of your query and target sequences. The amount of memory reserved for KMatch can be modified using the -km_mem parameter which defaults to 100Gb.
    - The number of slaves, threads per slave and memory limit per slave are specified using the -slaves, -threads and -sl_mem parameters.
    - The default is to run one single-threaded slave using 100Gb of memory. 
    - The satsuma_run.sh file is used by SatsumaSynteny2 to start the slaves. 
    - Before running SatsumaSynteny2, you need to modify this file to suit your HPC environment by commenting out the lines you don't need with #. Y
    - You will also need to change 'QueueName' to a queue that exists on your system.


4. Edit satsuma_run.sh for SLURM
      ```
     #!/bin/bash

     # Script for starting Satsuma jobs on different job submission environments
     # One section only should be active, ie. not commented out
   
     # Usage: satsuma_run.sh <current_path> <kmatch_cmd> <ncpus> <mem> <job_id> <run_synchronously>
     # mem should be in Gb, ie. 100Gb = 100
     
     # no submission system, processes are run locally either synchronously or asynchronously
     if [ "$6" -eq 1 ]; then
       eval "$2"
     else
       eval "$2" &
     fi
     
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
     sbatch -p p_ccib_1 -c $3 -J $5 -o ${5}.log --mem ${4}G slurm_tmp.sh
     ```


5. Run Satsuma

   ```
   ./SatsumaSynteny2 -q query.fa -t target.fa -o output_dir
   ```









   
