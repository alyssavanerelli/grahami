# Resources
[Daren Card Github Page](https://gist.github.com/darencard/bb1001ac1532dd4225b030cf0cd61ce2)

# software and data needed
## software
1. [RepeatModeler](http://www.repeatmasker.org/RepeatModeler/) and [RepeatMasker](http://www.repeatmasker.org/RMDownload.html) with all dependencies and [RepBase](https://www.girinst.org/repbase/)
2. MAKER MPI 
3. [Augustus](http://bioinf.uni-greifswald.de/augustus/)
4. BUSCO
5. [SNAP](http://korflab.ucdavis.edu/software.html)
6. [BEDtools](https://bedtools.readthedocs.io/en/latest/)

**_maker, RepeatModeler, RepeatMasker, Augustus, and SNAP are included with singularity that is already installed_**

## data/resources
1. assembled reference genome, in fasta format
2. protein sequences from related species, in fasta format
   - for this assembly we used two species: _Anolis sagrei_ and _Sceloporus undulatus_
   - did not use _carolinensis_ because _sagrei_ annotations have those present in _carolinensis_ and more


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

<details><summary>example</summary>
<p>

```
singularity shell --cleanenv /projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

Singularity maker:2.31.11-repbase.sif:/projectsc/f_geneva_1/alyssa/grahami/annotation> 
/usr/local/share/RepeatMasker/famdb.py -i /usr/local/share/RepeatMasker/Libraries/RepeatMaskerLib.h5 names Anolis_carolinensis
```

</p>
</details>

## make .sh files to run maker

**1. `r1maker_sub.sh`**
- This script will submit maker using the protein homology sequences to annotate the genome
- This is the first script to be submitted
- Used 2 whole cores to run this 

  **output**
  - `AnoGra1.1.maker.output`

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
  - `AnoGra1.1.maker.output/snap/braker`

---

**3. `r1maker_gff.sh`**
- This script will create gff files to be used later
- Can submit this after `r1maker_bsh.sh` finishes

  **output**
  - This step will make 3 files
    - `AnoGra_rnd1.all.maker.est2genome.gff`
      - This file will be empty because in round 1 we did not do any gene annotations using est2genome
    - `AnoGra_rnd1.all.maker.protein2genome.gff`
    - `AnoGra_rnd1.all.maker.repeats.gff`

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

- If the busco online server is down
  - copy `busco_downloads/` folder over to `annotation/` from `busco/`
  - add `--offline` to the busco command in the `r1maker_aug.sh` script
    - this will force busco to use the datasets already downloaded instead of searching online for new files
 
 
  **output**
  - `AnoGra_rnd1_aug`

- Need to move some of the augustus output to our **Augustus path**
  - Will be creating a folder in species with our trained gene models

```
cd AnoGra_rnd1_aug/run_vertebrata_odb10/augustus_output/retraining_parameters/

#rename folder
mv BUSCO_AnoGra_rnd1_aug/ Anolis_grahami/

#rename files within folder
cd Anolis_grahami/

rename BUSCO_AnoGra_rnd1_aug Anolis_grahami *

#also need to rename these strings within some of the files
sed -i 's/BUSCO_AnoGra_rnd1_aug/Anolis_grahami/g' Anolis_grahami_parameters.cfg
sed -i 's/BUSCO_AnoGra_rnd1_aug/Anolis_grahami/g' Anolis_grahami_parameters.cfg.orig1 

cp -R Anolis_grahami/ /home/av795/Augustus/config/species/
#now we will use this Anolis_grahami species in our augustus path as input for round 2 of maker
```

---

**5. `r1maker_trans_aug.sh`**
- Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database

  **output**
  - `AnoGra_annotation_eval1_1`

---

**Count the number of gene models and gene lengths after each round**
- can assess when to stop doing more rounds
- more rounds does not always mean better, we want to do a few but not too many

```
cat <roundN.full.gff> | awk '{ if ($3 == "gene") print $0 }' | awk '{ sum += ($5 - $4) } END { print NR, sum / NR }'
```


## Important Info
- After round 1 of maker has completed, copy the original control file: `maker_opts.ctl` to `maker_opts_rnd1.ctl`
- Now for the next round, just modify the original `maker_opts.ctl` file
- The `maker_exe.ctl` and `maker_bopts.ctl` can remain unmodified

# round 2
- This round will not do the annotation via protein homology because this was completed in the first round and does not need to be done again.
- This will train the programs to better recognize new _grahami_ genes
- We will use the gene models generated from the first round

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

---

**3. `r2maker_bsh.sh`**

---

**4. `r2maker_gff.sh`**

---

**5. `r2maker_aug.sh`**

---

**6. `r2maker_trans_aug.sh`**

---







