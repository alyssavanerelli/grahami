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
   - for this assembly we used two species: _Anolis sagrei_ and _Anolis carolinensis_
3. EST data from _Anolis sagrei_
   - used limb data

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

<details><summary>maker_opts_rnd1.ctl</summary>
<p>

```
#-----Genome (these are always required)
genome=/projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa #genome sequence (fasta file or fasta embeded in GFF3 file)
organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic

#-----Re-annotation Using MAKER Derived GFF3
maker_gff= #MAKER derived GFF3 file
est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no

#-----EST Evidence (for best results provide a file for at least one)
est= #set of ESTs or assembled mRNA-seq in fasta format
altest= #EST/cDNA sequence file in fasta format from an alternate organism
est_gff= #aligned ESTs or mRNA-seq from an external GFF3 file
altest_gff= #aligned ESTs from a closly relate species in GFF3 format

#-----Protein Homology Evidence (for best results provide a file for at least one)
protein=/projects/f_geneva_1/alyssa/grahami/annotation/proteomes/SceUnd1.1_protein.faa,/projects/f_geneva_1/alyssa/grahami/annotation/proteomes/AnoSag2.1_proteins.fa,/projects/f_geneva_1/alyssa/grahami/annotation/proteomes/AnoCar2.0_protein_GCF_000090745.1.faa #protein sequence file in fasta format (i.e. from mutiple oransisms)
protein_gff=  #aligned protein homology evidence from an external GFF3 file

#-----Repeat Masking (leave values blank to skip repeat masking)
model_org=Anolis_carolinensis #select a model organism for DFam masking in RepeatMasker
rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
repeat_protein= #provide a fasta file of transposable element proteins for RepeatRunner
rm_gff= #pre-identified repeat elements from an external GFF3 file
prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)

#-----Gene Prediction
snaphmm= #SNAP HMM file
gmhmm= #GeneMark HMM file
augustus_species= #Augustus gene prediction species model
fgenesh_par_file= #FGENESH parameter file
pred_gff= #ab-initio predictions from an external GFF3 file
model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
protein2genome=1 #infer predictions from protein homology, 1 = yes, 0 = no
trna=0 #find tRNAs with tRNAscan, 1 = yes, 0 = no
snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no

#-----Other Annotation Feature Types (features MAKER doesn't recognize)
other_gff= #extra features to pass-through to final MAKER generated GFF3 file

#-----External Application Behavior Options
alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
cpus=1 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)

#-----MAKER Behavior Options
max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
min_contig=1000 #skip genome contigs below this length (under 10kb are often useless)

pred_flank=200 #flank for extending evidence clusters sent to gene predictors
pred_stats=0 #report AED and QI statistics for all predictions as well as models
AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
min_protein=0 #require at least this many amino acids in predicted proteins
alt_splice=0 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)

split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes

tries=5 #number of times to try a contig if there is a failure for some reason
clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
TMP= #specify a directory other than the system default temporary directory for temporary files
```

</p>
</details>


## make .sh files to run maker

**1. `r1maker_sub.sh`**
- This script will submit maker using the protein homology sequences to annotate the genome
- This is the first script to be submitted
- Used 2 whole cores to run this 

  **output**
  - `Agra_rnd1.maker.output`

<details><summary>r1maker_sub.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_sub_rnd1
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=0
#SBATCH -n 20
#SBATCH -N 2
#SBATCH --exclusive
#SBATCH --time=8-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=END,FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation

module purge
module load singularity/3.1.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

# NOTE: empty MAKER control files can be generated using the command:
#       singularity exec ${MAKER_IMAGE} maker -CTL 
# This will be needed at least for the maker_exe.ctl file, which has the paths to executables in the container.
# Otherwise, existing maker_bopts.ctl and maker_opts.ctl should be usable.

# Submit this job script from the directory with the MAKER control files


# optional repeat masking (if not using RepeatMasker, comment-out these three lines)
export SINGULARITYENV_LIBDIR=${PWD}/LIBDIR

#These commands need to be run once and then can be commented out for all subseqeunt MAKER RUNS
#mkdir -p LIBDIR
#singularity exec ${MAKER_IMAGE} sh -c 'ln -sf /usr/local/share/RepeatMasker/Libraries/* LIBDIR'

# singularity options:
# * --cleanenv : don't pass environment variables to container (except those specified in --env option-arguments)
# * --no-home : don't mount home directory (if not current working directory) to avoid any application/language startup files
# Add any MAKER options after the "maker" command
# * -nodatastore is suggested for Lustre, as it reduces the number of directories created
# * -fix_nucleotides needed for hsap_contig.fasta example data

singularity exec --no-home --cleanenv ${MAKER_IMAGE} mpiexec -n 20 maker -base Agra_rnd1 -fix_nucleotides -nodatastore
```

</p>
</details>

---

**2. `r1maker_bsh_gff.sh` and `r1maker_bsh_n.sh`**
- This is the next script to be submitted
- This will train the gene model software `SNAP`
- This will make some .gff files that are needed for `r1maker_gff.sh`
- This will also make files needed for `r1maker_aug.sh`
- Used the file with "n" because we did not use any filters for this run
- Ideally want to use an aed of at least 0.25 and a length of 50 amino acids (`-x 0.25 -l 50`) - to give MAKER good gene models
  - We did not get output when using these criteria so we used the `-n` flag which means no criteria
  - **We have to do filtering manually with the code below**

**Run scripts in this order**
- `r1maker_bsh_gff.sh`
  - this will make the gff files to be filtered
- `snap_filtering.sh`
  - this will manually filter the gff files to only keep gene models with AED scores of less than 0.25 and lengths of greater than 50 bp
- `r1maker_bsh_n.sh`
  - this will run snap with the properly filtered gff file



  **output**
  - `Agra_rnd1.maker.output/snap/braker`
  - **you will need to make sure that the files in this folder are not empty!!**
    - if they are empty, make sure you have ran the scripts in the correct order. SNAP needs to be given the properly filtered file.

<details><summary>r1maker_bsh_gff.sh</summary>
<p>
   
```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_bsh_gff_rnd1
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=0-10:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif


echo "##### Generate GFF files with and without the sequences"
singularity exec ${MAKER_IMAGE} gff3_merge -s -d Agra_rnd1_master_datastore_index.log > Agra_rnd1.all.maker.gff
singularity exec ${MAKER_IMAGE} fasta_merge -d Agra_rnd1_master_datastore_index.log

echo "##### GFF w/o the sequences"
singularity exec ${MAKER_IMAGE} gff3_merge -n -s -d Agra_rnd1_master_datastore_index.log > Agra_rnd1.all.maker.noseq.gff

echo "##### done"
```

</p>
</details>


**SNAP filtering not working**
- it has come to our attention, that SNAP filtering in the first maker runs was not working, as we do have genes that are <50 aa with AED>0.25
- to fix this, I will be manually filtering the gff files, and then running the bsh script

<details><summary>snap_filter.sh</summary>
<p>

```
#!/bin/bash

echo "######## define variables"
RND="2"

FOLDER="/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd${RND}.maker.output"
OG_NOSEQ_GFF="Agra_rnd${RND}.all.maker.noseq.gff"
OG_SEQ_GFF="Agra_rnd${RND}.all.maker.gff"
NEW_NOSEQ_GFF="Agra_rnd${RND}.all.maker.noseq.filtered.gff"
NEW_SEQ_GFF="Agra_rnd${RND}.all.maker.seq.filtered.gff"


echo "######## make file only containing gene models to keep"
cd ${FOLDER}

echo "### make gff file with all scaffold IDs, AED scores, and lengths"
make_gff="grep \"AED\" ${OG_NOSEQ_GFF} | cut -f 9 | cut -d \";\" -f 1,4,6 | cut -d \"|\" -f 1,9 > temp_all.aed.len.gff"
#echo $make_gff
eval $make_gff
sed -i 's/;_/;/g' temp_all.aed.len.gff
sed -i 's/QI=[0-9]|/len=/g' temp_all.aed.len.gff
sed -i 's/QI=[0-9][0-9]|/len=/g' temp_all.aed.len.gff

echo "### make file without naming"
cp temp_all.aed.len.gff temp_all.aed.len.noname.gff
sed -i 's/AED=//g' temp_all.aed.len.noname.gff
sed -i 's/len=//g' temp_all.aed.len.noname.gff
sed -i 's/;/ /g' temp_all.aed.len.noname.gff

echo "### filter file to only keep lines with AED<=0.25 and len>=50"
awk '$2 <=0.25' temp_all.aed.len.noname.gff > temp_filtered.aed.len.gff
awk '$3 >=50' temp_filtered.aed.len.gff > len.gff ; mv len.gff temp_filtered.aed.len.gff

echo "### make file with only scaffold names"
names="cat temp_filtered.aed.len.gff | cut -d \" \" -f 1 > temp_filtered.names.gff"
#echo $names
eval $names
sed -i 's/-mRNA-1//g' temp_filtered.names.gff

echo "### make file of all gene model names"
gene_names="cat temp_all.aed.len.noname.gff | cut -d \" \" -f 1 > temp_all.names.gff"
#echo $gene_names
eval $gene_names

echo "### filter name file to only include the bad models"
grep -f temp_filtered.names.gff -Fw -v temp_all.names.gff > temp_badmodels.gff
sed -i 's/-mRNA-1//g' temp_badmodels.gff

echo "### filer noseq.gff file to include all lines EXCEPT these bad gene models"
make_new_noseq="grep -f temp_badmodels.gff -Fw -v ${OG_NOSEQ_GFF} > ${NEW_NOSEQ_GFF}"
#echo $make_new_noseq
eval $make_new_noseq

echo "### our bsh.sh file needs us to also have the fasta sequence pasted at the bottom"
make_new_seq="grep \"##FASTA\" -A 24000000 ${OG_SEQ_GFF} > temp_seq.gff"
#echo $make_new_seq
eval $make_new_seq

combine="cat ${NEW_NOSEQ_GFF} temp_seq.gff > ${NEW_SEQ_GFF}"
#echo $combine
eval $combine

echo "### now need to delete all the temp files made"
rm temp_*

echo "done"
```

</p>
</details>

Next, we can give pass this `Agra_rnd1.all.maker.seq.filtered.gff` file to the `singularity exec ${MAKER_IMAGE} maker2zff` command in our `bsh_n.sh` file


<details><summary>r1maker_bsh_n.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_bsh_rnd1
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=0-10:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

echo "##### running SNAP"
mkdir snap
mkdir snap/braker
cd snap/braker
echo "# export 'confident' gene models from MAKER and rename to something meaningful"
singularity exec ${MAKER_IMAGE} maker2zff -n ../../Agra_rnd1.all.maker.seq.filtered.gff
rename genome Agra_rnd1.zff.length5_aed0.25  *
echo "# gather some stats and validate"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd1.zff.length5_aed0.25.ann Agra_rnd1.zff.length5_aed0.25.dna -gene-stats > gene-stats.log 2>&1
singularity exec ${MAKER_IMAGE} fathom Agra_rnd1.zff.length5_aed0.25.ann Agra_rnd1.zff.length5_aed0.25.dna -validate > validate.log 2>&1
echo "# collect the training sequences and annotations, plus 1000 surrounding bp for training"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd1.zff.length5_aed0.25.ann Agra_rnd1.zff.length5_aed0.25.dna -categorize 1000 > categorize.log 2>&1
singularity exec ${MAKER_IMAGE} fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
echo "# create the training parameters"
mkdir params
cd params
singularity exec ${MAKER_IMAGE} forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

echo "#### assemble the HMM"
singularity exec ${MAKER_IMAGE} hmm-assembler.pl Agra_rnd1.zff.length5_aed0.25 params > Agra_rnd1.zff.length5_aed0.25.hmm

awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ../../Agra_rnd1.all.maker.noseq.gff |   awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' |   bedtools getfasta -fi /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa -bed - $

echo "#### done"
```

</p>
</details>

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

<details><summary>r1maker_gff.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_gff_rnd1
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=32000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=0-05:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output

echo "#### transcript alignments"
awk '{ if ($2 == "est2genome") print $0 }' Agra_rnd1.all.maker.noseq.filtered.gff > Agra_rnd1.all.maker.est2genome.gff

echo "#### protein alignments"
awk '{ if ($2 == "protein2genome") print $0 }' Agra_rnd1.all.maker.noseq.filtered.gff > Agra_rnd1.all.maker.protein2genome.gff

echo "#### repeat alignments"
awk '{ if ($2 ~ "repeat") print $0 }' Agra_rnd1.all.maker.noseq.filtered.gff > Agra_rnd1.all.maker.repeats.gff

echo "#### done"
```

</p>
</details>

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

<details><summary>r1maker_aug.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_aug_rnd1
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=90G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=9-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

eval "$(conda shell.bash hook)"
conda activate busco

export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config 

echo "#### Train Augustus gene models through BUSCO using the vertebrata_odb10 dataset"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/snap/braker/Agra_rnd1.all.maker.transcripts1000.fasta \
-f -o Agra_rnd1_aug --offline -l vertebrata_odb10 -m genome -c 30 --augustus --augustus_species human --long \
--augustus_parameters='--progress=true' >busco_aug_rnd1_log.txt  2>&1

echo "#### done"
```

</p>
</details>

**now need to go into this directory and rename things for downstream analyses**

<details><summary>rename_aug.sh</summary>
<p>
   
   ```
   #!/bin/bash

   echo "######## define variables"
   RND="1"
   FOLDER="/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd${RND}_aug"


   echo "######## go into augustus folder"
   cd ${FOLDER}/run_vertebrata_odb10/augustus_output/retraining_parameters/


   echo "######## rename folder"
   mv BUSCO_Agra_rnd${RND}_aug/ Anolis_grahami/


   echo "######## rename files within folder"
   cd Anolis_grahami/
   rename BUSCO_Agra_rnd${RND}_aug Anolis_grahami *


   echo "######## rename strings within 2 files"
   sed -i 's/BUSCO_Agra_rnd${RND}_aug/Anolis_grahami/g' Anolis_grahami_parameters.cfg
   sed -i 's/BUSCO_Agra_rnd${RND}_aug/Anolis_grahami/g' Anolis_grahami_parameters.cfg.orig1


   echo "######## copy this folder to our augustus folder"
   cd ${FOLDER}/run_vertebrata_odb10/augustus_output/retraining_parameters/
   cp -R Anolis_grahami/ /home/av795/Augustus/config/species/


   echo "done"

   ```
   
</p>
</details>

---

**5. `r1maker_trans_aug.sh`**
- Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database

  **output**
  - `Agra_annotation_eval1`

<details><summary>r1maker_trans_aug.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_aug-trans_rnd1
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=128G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif



eval "$(conda shell.bash hook)"
conda activate busco


export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config


echo "##### Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/Agra_rnd1.all.maker.transcripts.fasta \
-o Agra_annotation_eval_rnd1 -l vertebrata_odb10 -m transcriptome -c 8 --augustus_species human \
--augustus_parameters='--progress=true' >busco_aug_rnd1_transc.txt
   
echo "##### done"
```

</p>
</details>

---


## Important Info
- After round 1 of maker has completed, copy the original control file: `maker_opts.ctl` to `maker_opts_rnd1.ctl`
- Now for the next round, just modify the original `maker_opts.ctl` file
- The `maker_exe.ctl` and `maker_bopts.ctl` can remain unmodified


# After each round
- check stats and AED scores

## Number of gene models and gene lengths for each round
- count the number of gene models and the average gene lengths after each round
- can assess when to stop doing more rounds
- more rounds does not always mean better, we want to do a few but not too many

```
cat <roundN.full.gff> | awk '{ if ($3 == "gene") print $0 }' | awk '{ sum += ($5 - $4) } END { print NR, sum / NR }'
```

## Number of gene models and gene lengths for each round - old stats

| Round   | # gene models | gene lengths |
| :-----: | :-----------: | :----------: |
| Round 1 | 107979        |      2340.89 |
| Round 2 | 47152         |      7430.67 |
| Round 3 | 47810         |      5087.77 |
| Round 4 | 52494         |      6518.57 |
| Round 5 | 52829         |      6579.63 |

   
### New stats with manual SNAP filtering 

| Round   | filtered # gene models  | filtered gene lengths | unfiltered # gene models | unfiltered gene lengths | %C    | %M    | %F    |
| :-----: | :---------------------: | :-------------------: | :----------------------: | :---------------------: | :---: | :---: | :---: |
| Round 1 | 27695                   | 3113.21               | 107979                   | 2340.89                 | 58.1% | 28.2% | 13.7% |
| Round 2 | 16252                   | 6149.11               | 62864                    | 3275.08                 | 44.5% | 37.6% | 17.9% |
| Round 3 | 15173                   | 7185.48               | 48964                    | 4997.88                 | 50.0% | 31.6% | 18.4% |
| Round 4 | 26035                   | 7609.45               | 52458                    | 6409.13                 | 57.1% | 26.1% | 16.8% |
| Round 5 | 15108                   | 6968.74               | 50974                    | 4867.14                 | 49.2% | 32.1% | 18.7% |
| Round 6 | 14949                   | 6820.09               | 51429                    | 4760.90                 | 48.4% | 32.5% | 19.1% |   
| filtered %C |
| :---------: |
| -----       |

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

Now we can look at this file in R
<details><summary>Maker_AED.R</summary>
<p>

```
###### Maker AED scores ######

#libraries
library(MetBrewer)

# read in data
rnd1 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd1", header = TRUE) 
rnd2 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd2", header = TRUE)
rnd3 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd3", header = TRUE)
rnd4 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd4", header = TRUE)
rnd5 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd5", header = TRUE)

# make plot
plot(rnd1$AED, rnd1$Agra_rnd1.maker.output.Agra_rnd1.all.maker.gff, col = "#d35e17", type = "line", xlab = "AED", ylab = "Frequency", lwd=2.0)
lines(rnd2$AED, rnd2$Agra_rnd2.maker.output.Agra_rnd2.all.maker.gff, col = "#e9b109",lwd=2.0)
lines(rnd3$AED, rnd3$Agra_rnd3.maker.output.Agra_rnd3.all.maker.gff, col = "#829d44",lwd=2.0)
lines(rnd4$AED, rnd4$Agra_rnd4.maker.output.Agra_rnd4.all.maker.gff, col = "blue",lwd=2.0)
lines(rnd5$AED, rnd5$Agra_rnd5.maker.output.Agra_rnd5.all.maker.gff, col = "orange",lwd=2.0)
legend(0.8,0.5,legend = c("rnd1", "rnd2", "rnd3", "rnd4","rnd5"), col = c("#d35e17", "#e9b109", "#829d44", "blue", "orange"), lty = 1, title = "Maker Round", lwd = 2.0)


### ggplot 

# load libraries
library(MetBrewer)
library(tidyverse)
library(ggplot2)

# load in data
rnd1 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd1", header = TRUE)
rnd2 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd2", header = TRUE)
rnd3 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd3", header = TRUE)
rnd4 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd4", header = TRUE)
rnd5 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_rnd5", header = TRUE)
aug_rnd2 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_augustus_rnd2", header = TRUE)
snap_rnd2 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_snap_rnd2", header = TRUE)
aug_rnd3 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_augustus_rnd3", header = TRUE)
snap_rnd3 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_snap_rnd3", header = TRUE)
aug_rnd4 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_augustus_rnd4", header = TRUE)
snap_rnd4 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_snap_rnd4", header = TRUE)
aug_rnd5 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_augustus_rnd5", header = TRUE)
snap_rnd5 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/AED_snap_rnd5", header = TRUE)
t_rnd1 = read.table("/projects/f_geneva_1/alyssa/grahami/annotation/test_rnd1/Agra_rnd1.maker.output/AED_test_rnd1", header = TRUE)



# add column for rounds
rnd1$Round = "rnd1"
rnd2$Round = "rnd2"
rnd3$Round = "rnd3"
rnd4$Round = "rnd4"
rnd5$Round = "rnd5"
snap_rnd2$Round = "rnd2_snap"
snap_rnd3$Round = "rnd3_snap"
snap_rnd4$Round = "rnd4_snap"
snap_rnd5$Round = "rnd5_snap"
aug_rnd2$Round = "rnd2_aug"
aug_rnd3$Round = "rnd3_aug"
aug_rnd4$Round = "rnd4_aug"
aug_rnd5$Round = "rnd5_aug"

# change column names
colnames(rnd1) = c("AED","Frequency", "Round")
colnames(rnd2) = c("AED","Frequency", "Round")
colnames(rnd3) = c("AED","Frequency", "Round")
colnames(rnd4) = c("AED","Frequency", "Round")
colnames(rnd5) = c("AED","Frequency", "Round")
colnames(snap_rnd2) = c("AED","Frequency", "Round")
colnames(snap_rnd3) = c("AED","Frequency", "Round")
colnames(snap_rnd4) = c("AED","Frequency", "Round")
colnames(snap_rnd5) = c("AED","Frequency", "Round")
colnames(aug_rnd2) = c("AED","Frequency", "Round")
colnames(aug_rnd3) = c("AED","Frequency", "Round")
colnames(aug_rnd4) = c("AED","Frequency", "Round")
colnames(aug_rnd5) = c("AED","Frequency", "Round")

# combine into a single dataframe
data_rnds_only = rbind(rnd1, rnd2,rnd3,rnd4,rnd5)
data_snap_aug = rbind(rnd1,snap_rnd2,snap_rnd3,snap_rnd4,snap_rnd5,aug_rnd2,aug_rnd3,aug_rnd4,aug_rnd5)

# plot data
ggplot(data = data_rnds_only, aes(x=AED,y=Frequency)) + geom_line(aes(color=Round)) +
  scale_color_manual(values = met.brewer("Signac",5))

ggplot(data = data_snap_aug, aes(x=AED,y=Frequency)) + geom_line(aes(color=Round)) +
  scale_color_manual(values = met.brewer("Signac",9))
```

## Testing snap vs augustus gene models
create files only containing AED scores from either snap or augustus gene models (for both rounds 2 and 3)
```
**create file with only AED scores**
grep "AED" Agra_rnd2.all.maker.gff > Agra_rnd2_AED.gff

**create aug and snap files**
grep -v "snap" Agra_rnd2_AED.gff > Agra_rnd2_AED_augustus.gff
grep -v "augustus" Agra_rnd2_AED.gff > Agra_rnd2_AED_snap.gff
```

</p>
</details>

Can visualize these files in R with the same code as above

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


  **main differences**
  - removes FASTA sequences to map and replaces them with the GFF files (`est_gff`, `protein_gff`, and `rm_gff`)
  - specify the path to the SNAP HMM and the species name for Augustus, so that these gene prediciton programs are run
  - switch `est2genome` and `protein2genome` to 0 so that gene predictions are based on the Augustus and SNAP gene models

<details><summary>maker_opts_rnd2.ctl</summary>
<p>

```
#-----Genome (these are always required)
genome=/projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa #genome sequence (fasta file or fasta embeded in GFF3 file)
organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic

#-----Re-annotation Using MAKER Derived GFF3
maker_gff= #MAKER derived GFF3 file
est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no

#-----EST Evidence (for best results provide a file for at least one)
est= #set of ESTs or assembled mRNA-seq in fasta format
altest= #EST/cDNA sequence file in fasta format from an alternate organism
est_gff= #aligned ESTs or mRNA-seq from an external GFF3 file
altest_gff= #aligned ESTs from a closly relate species in GFF3 format

#-----Protein Homology Evidence (for best results provide a file for at least one)
protein= #protein sequence file in fasta form
protein_gff=/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/Agra_rnd1.all.maker.protein2genome.gff #aligned protein homology evidence from an external GFF3 file

#-----Repeat Masking (leave values blank to skip repeat masking)
model_org= #select a model organism for DFam masking in RepeatMasker
rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
repeat_protein= #provide a fasta file of transposable element proteins for RepeatRunner
rm_gff=/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/Agra_rnd1.all.maker.repeats.gff #pre-identified repeat elements from an external GFF3 file
prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)

#-----Gene Prediction
snaphmm=/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/snap/braker/Agra_rnd1.zff.length5_aed0.25.hmm #SNAP HMM file
gmhmm= #GeneMark HMM file
augustus_species=Anolis_grahami #Augustus gene prediction species model
fgenesh_par_file= #FGENESH parameter file
pred_gff= #ab-initio predictions from an external GFF3 file
model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
protein2genome=0 #infer predictions from protein homology, 1 = yes, 0 = no
trna=1 #find tRNAs with tRNAscan, 1 = yes, 0 = no
snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no

#-----Other Annotation Feature Types (features MAKER doesn't recognize)
other_gff= #extra features to pass-through to final MAKER generated GFF3 file

#-----External Application Behavior Options
alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
cpus=1 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)

#-----MAKER Behavior Options
max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
min_contig=1000 #skip genome contigs below this length (under 10kb are often useless)

pred_flank=200 #flank for extending evidence clusters sent to gene predictors
pred_stats=0 #report AED and QI statistics for all predictions as well as models
AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
min_protein=0 #require at least this many amino acids in predicted proteins
alt_splice=0 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)

split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes

tries=5 #number of times to try a contig if there is a failure for some reason
clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
TMP= #specify a directory other than the system default temporary directory for temporary files
```

</p>
</details>

---

**2.`r2maker_sub.sh`**
- this will be the submission script to run a new iteration of maker using the gene models generated in the previous run
- I kept `Augustus/` in my home directory and removed the `--no-home` line from this submission script
- the line `-base Agra_rnd2` will make any files created during this run start with that text (this is important because it will avoid maker round 2 overwriting files from round 1)

   
<details><summary>r2maker_sub.sh</summary>
<p>
   
```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_sub_rnd2
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=0
#SBATCH -n 20
#SBATCH -N 2
#SBATCH --exclusive
#SBATCH --time=10-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation

module purge
module load singularity/3.1.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

# NOTE: empty MAKER control files can be generated using the command:
#	singularity exec ${MAKER_IMAGE} maker -CTL
# This will be needed at least for the maker_exe.ctl file, which has the paths to executables in the container.
# Otherwise, existing maker_bopts.ctl and maker_opts.ctl should be usable.

# Submit this job script from the directory with the MAKER control files


# optional repeat masking (if not using RepeatMasker, comment-out these three lines)
export SINGULARITYENV_LIBDIR=${PWD}/LIBDIR


#Set Augustus PATH
export SINGULARITYENV_AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config/
export SINGULARITYENV_AUGUSTUS_SCRIPTS_PATH=/home/av795/Augustus/scripts


#These commands need to be run once and then can be commented out for all subseqeunt MAKER RUNS
#mkdir -p LIBDIR
#singularity exec ${MAKER_IMAGE} sh -c 'ln -sf /usr/local/share/RepeatMasker/Libraries/* LIBDIR'

# singularity options:
# * --cleanenv : don't pass environment variables to container (except those specified in --env option-arguments)
# * --no-home : don't mount home directory (if not current working directory) to avoid any application/language startup files
# Add any MAKER options after the "maker" command
# * -nodatastore is suggested for Lustre, as it reduces the number of directories created
# * -fix_nucleotides needed for hsap_contig.fasta example data

singularity exec --cleanenv ${MAKER_IMAGE} mpiexec -n 20 maker -base Agra_rnd2 -fix_nucleotides   
```

</p>
</details>

   
---

**3. `r2maker_bsh_n.sh`**
- this will train snap gene models
- want to keep AED and length requirements (`-x` and `-l`)
  - these cutoffs still did not work
  - used `-n` flag still
- main changes from rnd1: change the names to be specific for rnd2

<details><summary>r2maker_bsh_gff.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_bsh_gff_rnd2
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=0-10:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif


echo "##### Generate GFF files with and without the sequences"
singularity exec ${MAKER_IMAGE} gff3_merge -s -d Agra_rnd2_master_datastore_index.log > Agra_rnd2.all.maker.gff
singularity exec ${MAKER_IMAGE} fasta_merge -d Agra_rnd2_master_datastore_index.log

echo "##### GFF w/o the sequences"
singularity exec ${MAKER_IMAGE} gff3_merge -n -s -d Agra_rnd2_master_datastore_index.log > Agra_rnd2.all.maker.noseq.gff

echo "##### done"
```

</p>
</details>

**Run `snap_filtering.sh` with RND 1 changed to 2**

<details><summary>r2maker_bsh_n.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_bsh_rnd2
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=0-10:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

echo "##### running SNAP"
mkdir snap
mkdir snap/braker
cd snap/braker
echo "# export 'confident' gene models from MAKER and rename to something meaningful"
singularity exec ${MAKER_IMAGE} maker2zff -n ../../Agra_rnd2.all.maker.seq.filtered.gff
rename genome Agra_rnd2.zff.length5_aed0.25  *
echo "# gather some stats and validate"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd2.zff.length5_aed0.25.ann Agra_rnd2.zff.length5_aed0.25.dna -gene-stats > gene-stats.log 2>&1
singularity exec ${MAKER_IMAGE} fathom Agra_rnd2.zff.length5_aed0.25.ann Agra_rnd2.zff.length5_aed0.25.dna -validate > validate.log 2>&1
echo "# collect the training sequences and annotations, plus 1000 surrounding bp for training"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd2.zff.length5_aed0.25.ann Agra_rnd2.zff.length5_aed0.25.dna -categorize 1000 > categorize.log 2>&1
singularity exec ${MAKER_IMAGE} fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
echo "# create the training parameters"
mkdir params
cd params
singularity exec ${MAKER_IMAGE} forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

echo "##### assemble the HMM"
singularity exec ${MAKER_IMAGE} hmm-assembler.pl Agra_rnd2.zff.length5_aed0.25 params > Agra_rnd2.zff.length5_aed0.25.hmm

awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ../../Agra_rnd2.all.maker.noseq.gff |   awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' |   bedtools getfasta -fi /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa -bed - $

echo "##### done"
```

</p>
</details>
   

---

**4. `r2maker_gff.sh`**
- main changes from rnd1: change the names to be specific for rnd2
   
   
<details><summary>r2maker_gff.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_gff_rnd2
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=32000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=0-05:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output

echo "#### transcript alignments"
awk '{ if ($2 == "est2genome") print $0 }' Agra_rnd2.all.maker.noseq.filtered.gff > Agra_rnd2.all.maker.est2genome.gff

echo "#### protein alignments"
awk '{ if ($2 == "protein2genome") print $0 }' Agra_rnd2.all.maker.noseq.filtered.gff > Agra_rnd2.all.maker.protein2genome.gff

echo "#### repeat alignments"
awk '{ if ($2 ~ "repeat") print $0 }' Agra_rnd2.all.maker.noseq.filtered.gff > Agra_rnd2.all.maker.repeats.gff

echo "#### done"
```

</p>
</details>

- as long as there is a 0 (no) on the est2genome line in the control file, the est2genome file will be empty

---

**5. `r2maker_aug.sh`**
- main changes from rnd1
  - change the names to be specific for rnd2
  - change species from `human` to `Anolis_grahami`
   
<details><summary>r2maker_aug.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_aug_rnd2
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=90G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=9-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

eval "$(conda shell.bash hook)"
conda activate busco

export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config

echo "#### Train Augustus gene models through BUSCO using the vertebrata_odb10 dataset"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output/snap/braker/Agra_rnd2.all.maker.transcripts1000.fasta \
-f -o Agra_rnd2_aug --offline -l vertebrata_odb10 -m genome -c 30 --augustus --augustus_species Anolis_grahami --long \
--augustus_parameters='--progress=true' >busco_aug_rnd2_log.txt  2>&1

echo "#### done"
```

</p>
</details>
   
   
**make sure to run `rename_aug.sh` with RND changed to 2 to update Anolis_grahami species folder in augustus**

---

**6. `r2maker_trans_aug.sh`**
   

<details><summary>r2maker_trans_aug.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_aug-trans_rnd2
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=128G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "#### load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif



eval "$(conda shell.bash hook)"
conda activate busco


export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config


echo "#### Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output/Agra_rnd2.all.maker.transcripts.fasta \
-o Agra_annotation_eval_rnd2 -l vertebrata_odb10 -m transcriptome -c 8 --augustus_species Anolis_grahami \
--augustus_parameters='--progress=true' >busco_aug_rnd2_transc.txt

echo "#### done"


```

</p>
</details>

---

# Round 3
   
1. **`maker_opts_rnd3.ctl`**
- **IMPORTANT:** Leave `protein_gff` and `rm_gff` set to round 1 because we are only generating these files once (during round 1 only). We will use these same files for each subsequent round.
- The only changes to the control file for all subsequent rounds
  - Change the `snaphmm` file to the most recent run
  - Make sure that you have updated the `Anolis_grahami` augustus folder (this should have been done already with the `rename_aug.sh` file
   
<details><summary>maker_opts_rnd3.ctl</summary>
<p>

```
#-----Genome (these are always required)
genome=/projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa #genome sequence (fasta file or fasta embeded in GFF3 file)
organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic

#-----Re-annotation Using MAKER Derived GFF3
maker_gff= #MAKER derived GFF3 file
est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no

#-----EST Evidence (for best results provide a file for at least one)
est= #set of ESTs or assembled mRNA-seq in fasta format
altest= #EST/cDNA sequence file in fasta format from an alternate organism
est_gff= #aligned ESTs or mRNA-seq from an external GFF3 file
altest_gff= #aligned ESTs from a closly relate species in GFF3 format

#-----Protein Homology Evidence (for best results provide a file for at least one)
protein= #protein sequence file in fasta form
protein_gff=/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/Agra_rnd1.all.maker.protein2genome.gff #aligned protein homology evidence from an external GFF3 file

#-----Repeat Masking (leave values blank to skip repeat masking)
model_org= #select a model organism for DFam masking in RepeatMasker
rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
repeat_protein= #provide a fasta file of transposable element proteins for RepeatRunner
rm_gff=/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd1.maker.output/Agra_rnd1.all.maker.repeats.gff #pre-identified repeat elements from an external GFF3 file
prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)

#-----Gene Prediction
snaphmm=/projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd2.maker.output/snap/braker/Agra_rnd2.zff.length5_aed0.25.hmm #SNAP HMM file
gmhmm= #GeneMark HMM file
augustus_species=Anolis_grahami #Augustus gene prediction species model
fgenesh_par_file= #FGENESH parameter file
pred_gff= #ab-initio predictions from an external GFF3 file
model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
protein2genome=0 #infer predictions from protein homology, 1 = yes, 0 = no
trna=1 #find tRNAs with tRNAscan, 1 = yes, 0 = no
snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no

#-----Other Annotation Feature Types (features MAKER doesn't recognize)
other_gff= #extra features to pass-through to final MAKER generated GFF3 file

#-----External Application Behavior Options
alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
cpus=1 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)

#-----MAKER Behavior Options
max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
min_contig=1000 #skip genome contigs below this length (under 10kb are often useless)

pred_flank=200 #flank for extending evidence clusters sent to gene predictors
pred_stats=0 #report AED and QI statistics for all predictions as well as models
AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
min_protein=0 #require at least this many amino acids in predicted proteins
alt_splice=0 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)

split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes

tries=5 #number of times to try a contig if there is a failure for some reason
clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
TMP= #specify a directory other than the system default temporary directory for temporary files
```

</p>
</details>

2. **`r3maker_sub.sh`** 
- change rnd2 to rnd3     
   
<details><summary>r3maker_sub.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_geneva_1
#SBATCH --account=general
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_sub_rnd3
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=0
#SBATCH -n 20
#SBATCH -N 2
#SBATCH --exclusive
#SBATCH --time=10-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation

module purge
module load singularity/3.1.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

# NOTE: empty MAKER control files can be generated using the command:
#	singularity exec ${MAKER_IMAGE} maker -CTL
# This will be needed at least for the maker_exe.ctl file, which has the paths to executables in the container.
# Otherwise, existing maker_bopts.ctl and maker_opts.ctl should be usable.

# Submit this job script from the directory with the MAKER control files


# optional repeat masking (if not using RepeatMasker, comment-out these three lines)
export SINGULARITYENV_LIBDIR=${PWD}/LIBDIR


#Set Augustus PATH
export SINGULARITYENV_AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config/
export SINGULARITYENV_AUGUSTUS_SCRIPTS_PATH=/home/av795/Augustus/scripts


#These commands need to be run once and then can be commented out for all subseqeunt MAKER RUNS
#mkdir -p LIBDIR
#singularity exec ${MAKER_IMAGE} sh -c 'ln -sf /usr/local/share/RepeatMasker/Libraries/* LIBDIR'

# singularity options:
# * --cleanenv : don't pass environment variables to container (except those specified in --env option-arguments)
# * --no-home : don't mount home directory (if not current working directory) to avoid any application/language startup files
# Add any MAKER options after the "maker" command
# * -nodatastore is suggested for Lustre, as it reduces the number of directories created
# * -fix_nucleotides needed for hsap_contig.fasta example data

singularity exec --cleanenv ${MAKER_IMAGE} mpiexec -n 20 maker -base Agra_rnd3 -fix_nucleotides
```

</p>
</details>
   
3. **`r3maker_bsh_gff.sh`**, **`snap_filter.sh`**, and **`r3maker_bsh_n.sh`**   
- change rnd2 to rnd3   
 
   
<details><summary>r3maker_bsh_gff.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_bsh_gff_rnd3
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=0-10:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd3.maker.output

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif


echo "##### Generate GFF files with and without the sequences"
singularity exec ${MAKER_IMAGE} gff3_merge -s -d Agra_rnd3_master_datastore_index.log > Agra_rnd3.all.maker.gff
singularity exec ${MAKER_IMAGE} fasta_merge -d Agra_rnd3_master_datastore_index.log

echo "##### GFF w/o the sequences"
singularity exec ${MAKER_IMAGE} gff3_merge -n -s -d Agra_rnd3_master_datastore_index.log > Agra_rnd3.all.maker.noseq.gff

echo "##### done"
```

</p>
</details>
   
   
`snap_filter.sh` with RND 2 changed to 3
   
   
<details><summary>r3maker_bsh_n.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_bsh_rnd3
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=64000
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=0-10:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL

cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd3.maker.output

module purge
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

echo "##### running SNAP"
mkdir snap
mkdir snap/braker
cd snap/braker
echo "# export 'confident' gene models from MAKER and rename to something meaningful"
singularity exec ${MAKER_IMAGE} maker2zff -n ../../Agra_rnd3.all.maker.seq.filtered.gff
rename genome Agra_rnd3.zff.length5_aed0.25  *
echo "# gather some stats and validate"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd3.zff.length5_aed0.25.ann Agra_rnd3.zff.length5_aed0.25.dna -gene-stats > gene-stats.log 2>&1
singularity exec ${MAKER_IMAGE} fathom Agra_rnd3.zff.length5_aed0.25.ann Agra_rnd3.zff.length5_aed0.25.dna -validate > validate.log 2>&1
echo "# collect the training sequences and annotations, plus 1000 surrounding bp for training"
singularity exec ${MAKER_IMAGE} fathom Agra_rnd3.zff.length5_aed0.25.ann Agra_rnd3.zff.length5_aed0.25.dna -categorize 1000 > categorize.log 2>&1
singularity exec ${MAKER_IMAGE} fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
echo "# create the training parameters"
mkdir params
cd params
singularity exec ${MAKER_IMAGE} forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..

echo "##### assembly the HMM"
singularity exec ${MAKER_IMAGE} hmm-assembler.pl Agra_rnd3.zff.length5_aed0.25 params > Agra_rnd3.zff.length5_aed0.25.hmm

awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' ../../Agra_rnd3.all.maker.noseq.gff |   awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' |   bedtools $

echo "##### done"
```

</p>
</details>
   
   
4. **`r3maker_gff.sh`**
- change rnd2 to rnd3      
   
   
<details><summary>r3maker_gff.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_gff_rnd3
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=32000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=0-05:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


cd /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd3.maker.output

echo "#### transcript alignments"
awk '{ if ($2 == "est2genome") print $0 }' Agra_rnd3.all.maker.noseq.filtered.gff > Agra_rnd3.all.maker.est2genome.gff

echo "#### protein alignments"
awk '{ if ($2 == "protein2genome") print $0 }' Agra_rnd3.all.maker.noseq.filtered.gff > Agra_rnd3.all.maker.protein2genome.gff

echo "#### repeat alignments"
awk '{ if ($2 ~ "repeat") print $0 }' Agra_rnd3.all.maker.noseq.filtered.gff > Agra_rnd3.all.maker.repeats.gff

echo "#### done"
```

</p>
</details>
   
   
5. **`r3maker_aug.sh`** and **`rename_aug.sh`**
- change rnd2 to rnd3      

<details><summary>r3maker_aug.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_geneva_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_aug_rnd3
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=90G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=9-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif

eval "$(conda shell.bash hook)"
conda activate busco

export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config

echo "#### Train Augustus gene models through BUSCO using the vertebrata_odb10 dataset"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd3.maker.output/snap/braker/Agra_rnd3.all.maker.transcripts1000.fasta \
-f -o Agra_rnd3_aug --offline -l vertebrata_odb10 -m genome -c 30 --augustus --augustus_species Anolis_grahami --long \
--augustus_parameters='--progress=true' >busco_aug_rnd3_log.txt  2>&1

echo "#### done"
```

</p>
</details>
   

`rename_aug.sh` with RND 2 changed to 3
   
   
6. **`r3maker_trans_aug.sh`**
- change rnd2 to rnd3    
   
<details><summary>r3maker_trans_aug.sh</summary>
<p>

```
#!/bin/bash
#SBATCH --partition=p_geneva_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=maker_aug-trans_rnd3
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/slurmout/slurm-%j-%x.out
#SBATCH --mem=128G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "#### load any Amarel modules that script requires"
module purge                                    # clears out any pre-existing modules
module load singularity/3.1.0
module load bedtools2/2.25.0

MAKER_IMAGE=/projects/f_geneva_1/programs/maker:2.31.11-repbase.sif



eval "$(conda shell.bash hook)"
conda activate busco


export AUGUSTUS_CONFIG_PATH=/home/av795/Augustus/config


echo "#### Evaluate gene predictions via BUSCO by comparing the transcript FASTA to the vertebrata_odb10 transcript database"
busco -i /projects/f_geneva_1/alyssa/grahami/annotation/Agra_rnd3.maker.output/Agra_rnd3.all.maker.transcripts.fasta \
-o Agra_annotation_eval_rnd3 -l vertebrata_odb10 -m transcriptome -c 8 --augustus_species Anolis_grahami \
--augustus_parameters='--progress=true' >busco_aug_rnd3_transc.txt

echo "#### done"
```

</p>
</details>
   
---
   
# Round 4

---

# Final Filtering

- We ran 6 rounds of MAKER and decided to use the annotation output from **round 4** since it was the best.
- We will now be filtering our gene models further. This code can be found [here]()
- In addition, we will be testing a new annotation program called TOGA. This code can be found [here]()

---
   

# Files to delete after annotation is finished
- we will need to delete intermediate files and files that we could make again (we have the scripts to do so) to save memory in our `f_geneva_1` folder


   
   
   


# Common Issues

**Getting an Augustus error**

_Some examples of errors you may get_
```
--Next Contig--

Processing run.log file...
MAKER WARNING: The file Agra_rnd3.maker.output/Agra_rnd3_datastore/52/6D/scaffold_6982//theVoid.scaffold_6982/scaffold_6982.abinit_masked.0.Anolis_grahami.augustus
did not finish on the last run and must be erased
#---------------------------------------------------------------------
Now retrying the contig!!
SeqID: scaffold_6982
Length: 1589
Tries: 4!!
#---------------------------------------------------------------------
```

```
/usr/local/bin/augustus: ERROR
        Couldn't open the file with the weight matrix: BUSCO_Agra_rnd2_aug_weightmatrix.txt
```

This is indicating that there is something wrong with augustus and the files augustus is trying to find. First look to make sure that the files within `RoundX_aug/run_vertebrata_odb10/augustus_output/retraining_parameters/` were renamed correctly. Also make sure that the sed commands to rename the files within the `.cfg` files worked correctly because this is what points augustus to the correct files and they need to be properly named.
   
     
**Files within `snap/braker` are empty**   

This may happen because the file being input into snap is not filtered correctly. Make sure to run the `bsh` scripts in the correct order, running `snap_filter.sh` BEFORE running snap in the `bsh_n.sh` script.

   
   

<details><summary>name</summary>
<p>

</p>
</details>
