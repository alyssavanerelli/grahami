# Assembling _Anolis grahami_ mitochondrial genome

## Directory Structure

- `mtgenome`
  - `genome`
    - This is where the completed mtgenome will be stored
  - `reads`
    - _sagrei_ mtgenome (for seed and reference)
    - R1 and R2 _grahami_ reads
  - `slurmout`
    - where the slurm output files are going to be stored 
  - `config_generator.sh`
    - Don't know if we actually need this file
  - `grahami_150_41`
    - species information
  - `novo_config.txt`
    - information that will get passed to novoplasty
  - `run_novoplasty.sh`
    - this is the script we will `sbatch`


## Set up files and directories

1. Set up directories (`mtgenome`,`genome`,`reads`,`slurmout`)
---
2. Move raw reads and _sagrei_ mtgenome to `reads`
---
3. Run FastQC and Trimmomatic on raw reads
  - This will filter and trim low quality reads
  - will use R1 and R2 pairs
  - unzip files before running this program, if needed
  - run this inside of the `reads` directory

  <details><summary>FastQC and Trimmomatic Code</summary>
  <p>
    
    ```
    
    #!/bin/bash
    #SBATCH --partition=p_ccib_1                    # which partition to run the job, options are in the Amarel guide
    #SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
    #SBATCH --account=general
    #SBATCH --job-name=fastqc                       # job name for listing in queue
    #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/fastqc/slurm-%j-%x.out
    #SBATCH --mem=100G                              # memory to allocate in Mb
    #SBATCH -n 20                                   # number of cores to use
    #SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
    #SBATCH --time=3-00:00:00                       # maximum run time days-hours:minutes:seconds
    #SBATCH --requeue                               # restart and paused or superseeded jobs
    #SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
    #SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE      # email for the following reasons


    echo "load any Amarel modules that script requires"
    module purge                                    # clears out any pre-existing modules
    module load java                                # load any modules needed
    module load FastQC


    echo "Bash commands for the analysis you are going to run"

    readset="/projects/f_geneva_1/alyssa/grahami/DTG-SG-149"

    echo "##################### fastqc initial quality analysis"
    fastqc -t 20 \
    ${readset}_R1_001.fastq \
    ${readset}_R2_001.fastq \
    -o /projects/f_geneva_1/alyssa/grahami/fastqc
    echo "$(sacct -j ${SLURM_JOB_ID} --format=elapsed | sed -n -e 3p)"
  
    echo ""
    echo "##################### trimmomatic"
    java -jar /projects/ccib/geneva/programs/trimmomatic/trimmomatic-0.39.jar PE \
    -threads 20 -phred33 -trimlog ${readset}_trim.log \
    ${readset}_R1_001.fastq ${readset}_R2_001.fastq \
    ${readset}_filtered.R1.fq ${readset}_filtered.unpaired.R1.fq \
    ${readset}_filtered.R2.fq ${readset}_filtered.unpaired.R2.fq \
    ILLUMINACLIP:/projects/ccib/geneva/programs/trimmomatic/adapters/TruSeq3-PE-2.fa:2:30:10:4 \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:13:20 MINLEN:23
    echo "$(sacct -j ${SLURM_JOB_ID} --format=elapsed | sed -n -e 3p)"

    echo ""
    echo "##################### fastqc trimmomatic quality analysis"
    fastqc -t 20 \
    ${readset}_filtered.R1.fq \
    ${readset}_filtered.R2.fq \
    -o /projects/f_geneva_1/alyssa/grahami/fastqc
    echo "$(sacct -j ${SLURM_JOB_ID} --format=elapsed | sed -n -e 3p)"
 
    ### keep in if needed
    echo ""
    echo "##################### any other prep pre-assembly"
    echo "gunzip fastq.gz files"
    gunzip -c ${genomes}/${species}/${species}_filtered.R1.fq.gz > ${genomes}/${species}/${species}_filtered.R1.fq
    gunzip -c ${genomes}/${species}/${species}_filtered.R2.fq.gz > ${genomes}/${species}/${species}_filtered.R2.fq
    ```
    
  </p>
  </details>
  
  ---
4. Make species read file: `grahami_150_41.txt`
  - contains information about the species and the reads
  
  <details><summary>species read file code</summary>
  <p>
    
    ```
    mtgenome/reads
    DTG-SG-150_filtered.R1.fq
    DTG-SG-150_filtered.R2.fq
    150
    450
    ```
  
  </p>
  </details>
  
  ---
5. Set up config file: `novo_config.txt`
  - This will have the information regarding reads, kmer, seed, reference, etc. that novoplasty will use to assemble the mtgenome

  <details><summary>novo_config</summary>
  <p>
  
    ```
    Project:
    -----------------------
    Project name          = grahami_41
    Type                  = mito
    Genome Range          = 14000-22000
    K-mer                 = 41
    Max memory            = 155
    Extended log          = 0
    Save assembled reads  = no
    Seed Input            = /projects/f_geneva_1/alyssa/grahami/mtgenome/reads/AnoSag2_mtDNA_consensus.fasta
    Extend seed directly  = no
    Reference sequence    = /projects/f_geneva_1/alyssa/grahami/mtgenome/reads/AnoSag2_mtDNA_consensus.fasta
    Variance detection    =
    Chloroplast sequence  =

    Dataset 1:
    -----------------------
    Read Length           = 150
    Insert size           = 450
    Platform              = illumina
    Single/Paired         = PE
    Combined reads        =
    Forward reads         = /projects/f_geneva_1/alyssa/grahami/mtgenome/reads/DTG-SG-150_filtered.R1.fq
    Reverse reads         = /projects/f_geneva_1/alyssa/grahami/mtgenome/reads/DTG-SG-150_filtered.R2.fq
    Store Hash            =

    Heteroplasmy:
    -----------------------
    MAF                   =
    HP exclude list       =
    PCR-free              =

    Optional:
    -----------------------
    Insert size auto      = yes
    Use Quality Scores    = no
    Output path           = /projects/f_geneva_1/alyssa/grahami/mtgenome/genome
    ```
  
  </p>
  </details>

---
6. Set up `run_novoplasty.sh` file
  - This is the file that we will `sbatch` to run the program


  <details><summary>run_novoplasty.sh</summary>
  <p>
    
    ```
    #!/bin/bash


    #SBATCH --partition=cmain                       # which partition to run the job, options are in the Amarel guide
    #SBATCH --account=general
    #SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
    #SBATCH --job-name=NOVOPLASTY                   # job name for listing in queue
    #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/mtgenome/slurmout/slurm-%j-%x.out
    #SBATCH --mem=160G                              # memory to allocate in Mb
    #SBATCH -n 10                                   # number of cores to use
    #SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
    #SBATCH --time=3-00:00:00                       # maximum run time days-hours:minutes:seconds
    #SBATCH --no-requeue                            # restart and paused or superseeded jobs
    #SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
    #SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE	# email for the following reasons


    echo "load any Amarel modules that script requires"
    module purge                            #clears out any pre-existing modules
    module load java                        #needed by fastqc, trimmomatic
    module load FastQC                      #fastqc
    module load perl                        #needed by both assemblers



    perl /projects/f_geneva_1/programs/novoplasty/NOVOPlasty4.3.1.pl \
    -c /projects/f_geneva_1/alyssa/grahami/mtgenome/novo_config.txt
    ```

  </p>
  </details>






  
  
