# Resources
[Daren Card Github Page](https://gist.github.com/darencard/bb1001ac1532dd4225b030cf0cd61ce2)

# software and data needed
## software

**_maker, RepeatModeler, RepeatMasker, Augustus, and SNAP are included with singularity that is already installed_**

1. [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html) with all dependencies and [RepBase](https://www.girinst.org/repbase/)
2. MAKER MPI 
3. [Augustus](http://bioinf.uni-greifswald.de/augustus/)
4. BUSCO
5. [SNAP](http://korflab.ucdavis.edu/software.html)
6. [BEDtools](https://bedtools.readthedocs.io/en/latest/)


## data/resources
1. assembled reference genome, in fasta format
2. protein sequences from related species, in fasta format
   - for this assembly we used two species: _Anolis sagrei_ and _Sceloporus undulatus_
   - did not use _carolinensis_ because _sagrei_ annotations have those present in _carolinensis_ and more

# Important information to remember
- If a script fails for some reason (e.g. `r1maker_sub.sh`), all the files created from that submission script need to be deleted before running again

# make control files
```
module load singularity

srun -p p_ccib_1 singularity exec /projects/f_geneva_1/programs/maker:2.31.11-repbase.sif maker -CTL
```

this will create 3 files
1. **maker_bopts.ctl**
2. **maker_exe.ctl**
3. **maker_opts.ctl**

we are only required to modify maker_opts.ctl

do not modify maker_exe.ctl

**will modify this control file each run - _make new file each time_**

# round 1
## modify control file
input genome, protein homology evidence, repeat masker model org (_Anolis carolinensis_)

**how to find repeat masker model organism**

launch `singularity` and search for species name. more detail in code

```
singularity shell --cleanenv /projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

Singularity maker:2.31.11-repbase.sif:/projectsc/f_geneva_1/alyssa/grahami/annotation> 
/usr/local/share/RepeatMasker/famdb.py -i /usr/local/share/RepeatMasker/Libraries/RepeatMaskerLib.h5 names Anolis_carolinensis
```

## make .sh files to run maker

**1. `r1maker_sub.sh`**
- This script will submit maker using the protein homology sequences to annotate the genome
- This is the first script to be submitted
- Used 2 whole cores to run this 

  **output**
  - `Agra_rnd1.maker.output`

---

**2. `r1maker_bsh_n.sh`**
- This is the next script to be submitted
- This will train the gene model software `SNAP`
- This will make some .gff files that are needed for `r1maker_gff.sh`
- This will also make files needed for `r1maker_aug.sh`
- Used the file with "n" because we did not use any filters for this run
- Ideally want to use an aed of at least 0.25 and a length of 50 amino acids (`-x 0.25 -l 50`) - to give MAKER good gene models
  - We did not get output when using these criteria so we used the `-n` flag which means no criteria


  **output**
  - `Agra_rnd1.maker.output/snap/braker`

---

**3. `r1maker_gff.sh`**
- This script will create gff files to be used later
- Can submit this after `r1maker_bsh.sh` finishes

  **output**
  - This step will make 3 files
    - `Agra_rnd1.all.maker.est2genome.gff`
      - This file will be empty because in round 1 we did not do any gene annotations using est2genome
    - `Agra_rnd1.all.maker.protein2genome.gff`
    - `Agra_rnd1.all.maker.repeats.gff`

---

**4. `r1maker_aug.sh`**
- Can be run after `r1maker_gff.sh` and `r1maker_bsh.sh` are finished as it uses some files created by those scripts as input
- This will train `Augustus` gene models through BUSCO using the vertebrata_odb10 dataset

- **Need to download new Augustus config file**
  ```
  cd
  git clone https://github.com/Gaius-Augustus/Augustus.git
  ```
  - In the submission script, we will define the path to this config folder
  - To avoid issues where MAKER cannot find the right scripts, there are 2 options
    - keep `Augustus/` folder in home directory
      - there cannot be any programs in `/home/av795/bin/` that will interfere with maker (e.g. snap, augustus, etc.)
      - remove the `--no-home` line from your inital maker submission script (last line in `r2maker_sub.sh`)
    - move `Augustus/` folder to your folder in `/projects/` 
      - with this option, you will KEEP the `--no-home` line in the submission script
    - whichever option you choose, just be consistent


- If the busco online server is down
  - copy `busco_downloads/` folder over to `annotation/` from `busco/`
  - add `--offline` to the busco command in the `r1maker_aug.sh` script
    - this will force busco to use the datasets already downloaded instead of searching online for new files
 
 
  **output**
  - `Agra_rnd1_aug`

- Need to move some of the augustus output to our **Augustus path**
  - Will be creating a folder in species with our trained gene models

```
cd Agra_rnd1_aug/run_vertebrata_odb10/augustus_output/retraining_parameters/

#rename folder
mv BUSCO_Agra_rnd1_aug/ Anolis_grahami/

#rename files within folder
cd Anolis_grahami/

rename BUSCO_Agra_rnd1_aug Anolis_grahami *

#also need to rename these strings within some of the files
sed -i 's/BUSCO_Agra_rnd1_aug/Anolis_grahami/g' Anolis_grahami_parameters.cfg
sed -i 's/BUSCO_Agra_rnd1_aug/Anolis_grahami/g' Anolis_grahami_parameters.cfg.orig1 

cp -R Anolis_grahami/ /home/av795/Augustus/config/species/
#now we will use this Anolis_grahami species in our augustus path as input for round 2 of maker
```

---

**5. `r1maker_trans_aug.sh`**
- Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database

  **output**
  - `Agra_annotation_eval1`

---


## Important Info
- After round 1 of maker has completed, copy the original control file: `maker_opts.ctl` to `maker_opts_rnd1.ctl`
- Now for the next round, just modify the original `maker_opts.ctl` file
- The `maker_exe.ctl` and `maker_bopts.ctl` can remain unmodified

# round 2
- This round will not do the annotation via protein homology because this was completed in the first round and does not need to be done again.
- This will train the programs to better recognize new _grahami_ genes
- We will use the gene models generated from the first round

**copy submission files and change rnd1 to rnd2**
```
cp r1maker_bsh.sh r2maker_bsh.sh

sed -i -e 's/rnd1/rnd2/g' r2maker_bsh.sh
```

**1. modify control file: `maker_opts.ctl`**
  - Copy `maker_opts.ctl` to `maker_opts_rnd1.ctl`
  - Edit `maker_opts.ctl` for round 2
    - The code for this file is under `maker_opts_rnd2.ctl` (in github)

  **main differences**
  - removes FASTA sequences to map and replaces them with the GFF files (`est_gff`, `protein_gff`, and `rm_gff`)
  - specify the path to the SNAP HMM and the species name for Augustus, so that these gene prediciton programs are run
  - switch `est2genome` and `protein2genome` to 0 so that gene predictions are based on the Augustus and SNAP gene models

---

**2.`r2maker_sub.sh`**
- this will be the submission script to run a new iteration of maker using the gene models generated in the previous run
- I kept `Augustus/` in my home directory and removed the `--no-home` line from this submission script
- the line `-base Agra_rnd2` will make any files created during this run start with that text (this is important because it will avoid maker round 2 overwriting files from round 1)

---

**3. `r2maker_bsh.sh`**
- this will train snap gene models
- want to keep AED and length requirements (`-x` and `-l`)
  - these cutoffs still did not work
  - used `-n` flag still
- main changes from rnd1: change the names to be specific for rnd2

---

**4. `r2maker_gff.sh`**
- main changes from rnd1: change the names to be specific for rnd2
---

**5. `r2maker_aug.sh`**
- main changes from rnd1
  - change the names to be specific for rnd2
  - change species from `human` to `Anolis_grahami`
- change file names and copy over folder again 
  - before
      ```
      cd /home/av795/Augustus/config/species/
      mv Anolis_grahami/ Anolis_grahami_rnd1/
      ```
---

**6. `r2maker_trans_aug.sh`**

---



# Number of gene models and gene lengths for each round
- count the number of gene models and gene lengths after each round
- can assess when to stop doing more rounds
- more rounds does not always mean better, we want to do a few but not too many

```
cat <roundN.full.gff> | awk '{ if ($3 == "gene") print $0 }' | awk '{ sum += ($5 - $4) } END { print NR, sum / NR }'
```

## Number of gene models and gene lengths for each round

| Round   | # gene models | gene lengths |
| :-----: | :-----------: | :----------: |
| Round 1 | 107979        |      2340.89 |
| Round 2 | 47152         |      7430.67 |
| Round 3 | 47810         |      5087.77 |
| Round 4 | 52494         |      6518.57 |


## Visualize the AED distribution
- AED: annotation edit distance
- AED ranges from 0 to 1 and quantifies the confidence in a gene model based on empirical evidence
  - every gene model has an AED score
- the lower the AED, the better a gene model is likely to be
  - 0=great, 1=bad
- Ideally, 95% or more of the gene models will have an AED of 0.5 or better in the case of good assemblies.
- can use the script `AED_cdf_generator.pl` to do this
- X axis: AED, Y axis: frequency
- we will run this every round
- we want to see the line increase rapidly 

```
perl AED_cdf_generator.pl -b 0.025 <roundN.full.gff> > AED_rnd
```

# Testing snap vs augustus gene models
create files only containing AED scores from either snap or augustus gene models (for both rounds 2 and 3)
```
# create file with only AED scores
grep "AED" Agra_rnd2.all.maker.gff > Agra_rnd2_AED.gff

# create aug and snap files
grep -v "snap" Agra_rnd2_AED.gff > Agra_rnd2_AED_augustus.gff
grep -v "augustus" Agra_rnd2_AED.gff > Agra_rnd2_AED_snap.gff
```


# Files to delete after annotation is finished
- we will need to delete intermediate files and files that we could make again (we have the scripts to do so) to save memory in our `f_geneva_1` folder


- 





