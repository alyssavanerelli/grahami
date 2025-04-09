# Link Density Histogram
Using the programs [PretextMap](https://github.com/sanger-tol/PretextMap) and [PretextView](https://github.com/sanger-tol/PretextView).

## Installation
PretextMap can be installed through conda

```
conda create --name pretext
conda activate pretext
conda install bioconda::pretext-suite
```

## Softlink genome and HiC reads to this directory
```
ln -s /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa* /projects/f_geneva_1/alyssa/grahami/pretextmap/files/
ln -s /projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra/fastq/DTG-HiC-10* /projects/f_geneva_1/alyssa/grahami/pretextmap/files/
```

## Map HiC reads to genome with bwa

[bwa.sh]()


## Run PretextMap
- this program also uses `samtools view`
- _options:_
  - `-o` specifies an output file (required)
  - `--sortby` sorts contigs by length, name or nosort (default: length)
  - `--sortorder` ascend or descend (default: descend, no effect if sortby = nosort)
  - `--mapq` sets a minimum mapping quality filter (default: 10)

[pretext.sh](https://github.com/alyssavanerelli/grahami/blob/main/analyses/PretextMap/pretext.sh)

















