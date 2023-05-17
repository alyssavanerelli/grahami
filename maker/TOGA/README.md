# Using TOGA
- We will be using a new program TOGA to infer orthologs and classify genes as intact or lost
- We can use this in tandem with our MAKER output to improve completeness of annotation

# Resources
- [Paper describing TOGA](https://www.science.org/doi/10.1126/science.abn3107)
- [GitHub page](https://github.com/hillerlab/TOGA)
- [All code from paper](https://zenodo.org/record/6400671)

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















<details><summary>name</summary>
<p>

</p>
</details>
