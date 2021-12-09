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
  
3. 
