# Busco figure

- BUSCO has scripts that create figures with BUSCO scores using the short_summary stats generated after the BUSCO run is complete
- We will create a BUSCO figure for all the species used in the phylogeny

## Set up and Run script

**Directory Structure**
- `figures/`
  - `busco/`
    - This folder will contain all the short_summary...txt files from all the genomes
    - generate_plot.py will be here too
    - Also contains a script to run the generate_plot.py : `run_plot.sh`

1. Install ggplot2 to base directory

   ```
   module load R                     # Load R
   R                                 # Launch R
   >install.packages("ggplot2")      # Command to install gglot2 package in R
      [say yes to any options]
   >q()
   ```

2. Create the `generate_plot.py` file

   [github page](https://gitlab.com/ezlab/busco/-/blob/master/scripts/generate_plot.py)

   - copy this file exactly (copy paste)
   - To make sure this file is written properly, run this command: `python3 generate_plot.py -h`

3. Create the `run_plot.sh` file

   ```
   #!/bin/bash
   #SBATCH --partition=cmain                       # which partition to run the job, options are in the Amarel guide
   #SBATCH --account=general
   #SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
   #SBATCH --job-name=busco                        # job name for listing in queue
   #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/figures/busco/slurm-%j-%x.out
   #SBATCH --mem=50G                               # memory to allocate in Mb
   #SBATCH -n 1                                    # number of cores to use
   #SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
   #SBATCH --time=3-00:00:00                       # maximum run time days-hours:minutes:seconds
   #SBATCH --requeue                               # restart and paused or superseeded jobs
   #SBATCH --mail-user=av795@rutgers.edu           # email address to send status updates
   #SBATCH --mail-type=BEGIN,REQUEUE,FAIL,END      # email for the following reasons


   eval "$(conda shell.bash hook)"
   conda activate busco

   module load R

   cd /projects/f_geneva_1/alyssa/grahami/figures/busco

   python3 generate_plot.py -wd /projects/f_geneva_1/alyssa/grahami/figures/busco
   ```

3. Move all the busco output files over 
   - They are in this format: `short_summary.[generic|specific].dataset.label.txt`
     - Whatever is written where `label` is will be used as the species name for the figure

   ```
   cd /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/busco_out
   
   find . -name "short_summary.specific*" -type f -exec cp {} /projects/f_geneva_1/alyssa/grahami/figures/busco \;
   ```
   
4. Submit the `run_plot.sh` script


## Output
- This will return a couple of different files
  - `busco_figure.png`
    - This file will most likely be empty 
  - `busco_figure.R`
    - Script to open in R and generate plot
    - **Important:** If you have many species (~80 or above) you will need to split `my_species` object in R into 2 separate lists with half the species names each and then merge
      ```
      my_species_1 <- c()
      my_species_2 <- c()
      my_species <- c(my_species_1,my_species_2)
      ```
   
Can next use Adobe Illustrator to edit the figure!
   
   
