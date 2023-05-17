# Using TOGA
- We will be using a new program TOGA to infer orthologs and classify genes as intact or lost
- We can use this in tandem with our MAKER output to improve completeness of annotation

---

# Resources
- [Paper describing TOGA](https://www.science.org/doi/10.1126/science.abn3107)
- [GitHub page](https://github.com/hillerlab/TOGA)
- [All code from paper](https://zenodo.org/record/6400671)

---

# Installation
- TOGA was properly tested on Python v3.6.5 and v3.7.3
- TOGA requires [Nextflow](https://www.nextflow.io/)

**Install Nextflow**
```
conda create -n toga
conda activate toga
conda install -c bioconda nextflow
```

**Install TOGA**
```
# clone github repository
cd
git clone https://github.com/hillerlab/TOGA.git
cd TOGA
# install python packages needed
python3 -m pip install -r requirements.txt --user
# call configure to:
# 1) train xgboost models
# 2) download CESAR2.0
# 3) compile C code
./configure.sh
# run a test, it will take a couple of minutes
./run_test.sh micro
```
Should see `Success!` at the end.

**Running on slurm**
- Netflow requires a configuration file defining "executors" component
- These files for slurm are found [here](https://github.com/hillerlab/TOGA/tree/master/nextflow_config_files)
  - Contained here are three files: `call_cesar_config_template.nf`, `cesar_bigmem_config.nf`, and `extract_chain_features_config.nf`.

---

# Prepare files for TOGA
- TOGA has three required input files
  - Gene annotation of the reference genome (2bit format)
  - Genome alignment between the reference and query genome (bed-12 format)
  - Reference and query genome sequences

## Gene annotation of the reference genome
- This file needs to be in [bed-12 format](https://genome.ucsc.edu/FAQ/FAQformat.html#format1)

- **Isoform data**
  - TOGA can handle more than one isoform per gene so no need to reduce the number of transcripts to the isoform with the longest CDS
  - Isoform data increases annotation completeness and gene loss determination accuracy
  - If there is no isoform data given, each transcript is treated as a separate gene. 
  - **We do have this data for _Anolis carolinensis_**
    - Go to https://www.ensembl.org/biomart/martview
    - Choose Ensembl Genes N dataset and then **Green Anole** genes
    - Go to Filters tab, select "gene type" - protein coding
    - Go to Attributes tab, select:
      - Gene stable ID
      - Transcript stable ID
      - Uncheck all other marks!
    - Click results
    - Download the results as a tsv file

## Genome alignment between the reference and query genome
- This will be a **chain file**
  - Text file that describes chains
  - Chains are co-linear local alignments that occur in the same order on a reference and query chromosome
  - Collection of chains is a whole-genome pairwise alignment
  - [More explanation](http://genomewiki.ucsc.edu/index.php/Chains_Nets)
  - [Chain file format](https://genome.ucsc.edu/goldenPath/help/chain.html)
  - Each chain should have a unique identifier
  - Chain file can be gzipped = end needs to be `.chain.gz`

## Reference and query genome sequences
- These need to be in [2bit format](http://genome.ucsc.edu/FAQ/FAQformat.html#format7)
- Naming of chromosomes should be consistent between the 2bit file and the bed-12 file

---

# Running TOGA

```
./toga.py
```
- Need to provide:
  - Chain file containing genome alignment
  - Bed file containing reference genome annotaton
  - Path to reference genome 2bit file
  - Path to query genome 2bit file


**Need to figure out how to use this in tandem with maker annotations**

---

# Output











<details><summary>name</summary>
<p>

</p>
</details>
