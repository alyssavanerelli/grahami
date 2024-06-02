# snpEff
We will be annotating our variants using [SnpEff](https://pcingola.github.io/SnpEff/snpeff/introduction/)

## Install
```
cd

wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip

unzip snpEff_latest_core.zip
```

---

## Build database for genome
We will need to build a database for our genome following the instructions [here](https://pcingola.github.io/SnpEff/snpeff/build_db/)

### Configure a new genome in the config file
- To add a new genome, we will edit the configuration file `snpEff.config`
- Add the following lines to the bottom of this file (to quickly get to the bottom in nano: `^W` then `^V`)

```
# Anolis grahami genome
AnoGra.genome : AnoGra
```

### Build using gene annotations and reference sequences
- The files needed are:
  - Reference genome sequence
  - Gene annotations file
  - Sequences of CDS or proteins from the genome
- **We will be building a database using a GFF file**

**1. Make a new folder in `snpEff/`**
```
mkdir data
cd data/
mkdir AnoGra
```

**2. Now we will copy over the required files**
- It is very important that we name everything correctly or the database will not build properly

**Genome file (`sequences.fa`)**
- The genome file can be in one of two formats:
  - `snpEff/data/genomes/AnoGra1.1.fa`
  - `snpEff/data/AnoGra/sequences.fa`

```
cp /projects/f_geneva_1/alyssa/grahami/AnoGra1.1.fa /home/av795/snpEff/data/AnoGra/sequences.fa
```

**Annotation file (`genes.gff`)**

```
cd AnoGra
cp /projects/f_geneva_1/alyssa/grahami/annotation/filtering/final/final_genome_renamed.gff ./genes.gff
```

**Gene annotations file (`cds.fa`)**

We will make this CDS file using `gffread` (`-x` flag creates a CDS file: `gffread -x <out.fasta> -g <genome.fasta> <annotation.gff>`)

```
gffread -x cds.fa -g sequences.fa genes.gff
```

**Protein sequences file (`protein.fa`)**

We will make this file using `gffread` following the same format but this time using the `-y` option to export protein sequences

```
gffread -y protein.fa -g sequences.fa genes.gff
```

**3. Build the database**

Now we will create the database in an interactive job (this will create `.bin` files in the `AnoGra/` directory)

```
cd snpEff/
module load java
java -jar snpEff.jar build -gff3 -v AnoGra
```

### Check the database

---

## Run SnpEff
- Now we can run the program following [these instructions](https://pcingola.github.io/SnpEff/snpeff/running/)

First we will copy over our filtered `snp.vcf` file into `snpEff/` directory
```
cd snpEff/
cp /projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/snps/DTG-SG-149_snp_vcftools_filtered.vcf.recode.vcf .
mv DTG-SG-149_snp_vcftools_filtered.vcf.recode.vcf AnoGra.vcf
```

Now we can run `snpEff`
```
java -Xmx8g -jar snpEff.jar AnoGra AnoGra.vcf > AnoGra_out.vcf
```
