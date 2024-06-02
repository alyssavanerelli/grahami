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

---

## Output VCF file
- Full output information can be found [here](https://pcingola.github.io/SnpEff/snpeff/inputoutput/)
- The output VCF file is a tab-separated text file in this format:
  1. Chromosome name
  2. Position
  3. Variant's ID
  4. Reference genome
  5. Alternative (i.e. variant)
  6. Quality score
  7. Filter (whether or not the variant passed quality filters)
  8. INFO: Generic information about this variant. SnpEff adds annotation information in this column.
- SnpEff will also add information to the VCF header as well.
- Functional annotations are added to the info page using an **`ANN` tag**. Sub-fields meanings:
  1.  Allele (or ALT): In case of multiple ALT fields, this helps to identify which ALT we are referring to
  2.  Annotation (a.k.a. effect): Annotated using Sequence Ontology terms. Multiple effects can be concatenated using '&'.
  3.  Putative_impact: A simple estimation of putative impact / deleteriousness : `{HIGH, MODERATE, LOW, MODIFIER}`
  4.  Gene Name: Common gene name (HGNC). Optional: use closest gene when the variant is "intergenic".
  5.  Gene ID: Gene ID
  6.  Feature type: Which type of feature is in the next field (e.g. transcript, motif, miRNA, etc.). It is preferred to use Sequence Ontology (SO) terms, but 'custom' (user defined) are allowed.
  7.  Feature ID: Depending on the annotation, this may be: Transcript ID (preferably using version number), Motif ID, miRNA, ChipSeq peak, Histone mark, etc. Note: Some features may not have ID (e.g. histone marks from custom Chip-Seq experiments may not have a unique ID).
  8.  Transcript biotype: The bare minimum is at least a description on whether the transcript is {"Coding", "Noncoding"}. Whenever possible, use ENSEMBL biotypes.
  9.  Rank / total: Exon or Intron rank / total number of exons or introns.
  10.  HGVS.c: Variant using HGVS notation (DNA level)
  11.  HGVS.p: If variant is coding, this field describes the variant using HGVS notation (Protein level). Since transcript ID is already mentioned in 'feature ID', it may be omitted here.
  12.  cDNA_position / cDNA_len: Position in cDNA and trancript's cDNA length (one based).
  13.  CDS_position / CDS_len: Position and number of coding bases (one based includes START and STOP codons).
  14.  Protein_position / Protein_len: Position and number of AA (one based, including START, but not STOP).
  15.  Distance to feature: All items in this field are options, so the field could be empty
       - Up/Downstream: Distance to first / last codon
       - Intergenic: Distance to closest gene
       - Distance to closest Intron boundary in exon (+/- up/downstream). If same, use positive number.
       - Distance to closest exon boundary in Intron (+/- up/downstream)
       - Distance to first base in MOTIF
       - Distance to first base in miRNA
       - Distance to exon-intron boundary in splice_site or splice _region
       - ChipSeq peak: Distance to summit (or peak center)
       - Histone mark / Histone state: Distance to summit (or peak center)
  16. Errors, Warnings, or Information messages: Add errors, warnings, or informative message that can affect annotation accuracy.
- **`EFF`** field
  - **Effect:** Effect of this variant. See details here.
  - **Effect impact:**	Effect impact {High, Moderate, Low, Modifier}. See details here.
  - **Functional Class:**	Functional class {NONE, SILENT, MISSENSE, NONSENSE}.
  - **Codon_Change / Distance:**	Codon change: old_codon/new_codon OR distance to transcript (in case of upstream / downstream)
  - **Amino_Acid_Change:**	Amino acid change: old_AA AA_position/new_AA (e.g. 'E30K')
  - **Amino_Acid_Length:**	Length of protein in amino acids (actually, transcription length divided by 3).
  - **Gene_Name:**	Gene name
  - **Transcript_BioType:**	Transcript bioType, if available.
  - **Gene_Coding:**	`[CODING | NON_CODING]`. This field is 'CODING' if any transcript of the gene is marked as protein coding.
  - **Transcript_ID:**	Transcript ID (usually ENSEMBL IDs)
  - **Exon/Intron Rank:**	Exon rank or Intron rank (e.g. '1' for the first exon, '2' for the second exon, etc.)
  - **Genotype_Number:**	Genotype number corresponding to this effect (e.g. '2' if the effect corresponds to the second ALT)
  - **Warnings / Errors:**	Any warnings or errors (not shown if empty).






