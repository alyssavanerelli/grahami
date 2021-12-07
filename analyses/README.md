# next steps
## [juicer](grahami/analyses/juicer/README.md)
HiC maps - diagonal graph

using HiC assembly and reference genome

## busco phylogenomics
gather genomes of related species to be included in phylogenetic analyses

run BUSCO on each genome - will be used as input for busco_phylogenomics (default settings - except _-safe_ flag with IQ-TREE)

busco_phylogenomics will create trimmed alignments of genes that were present and single copy in all genomes, and infer phylogenies via either concatenation and phylogenetic analysis (IQ-Tree) or by inferring individual gene trees (IQ-TREE) and performing species tree inference (ASTRAL)

visualize with iTOL

## chromosome synteny
compare chromosome assembly with closely related species to assess synteny

Satsuma2 (default settings)
https://github.com/bioinfologics/satsuma2

identify chromosomal locations for related species, find syntenic scaffold between related species, compare these to our largest assembly scaffolds

Use R circlize package for visualization of chromosome synteny

## GC-content
Bedtools

divide largest scaffolds into 10kb windows (settings _-w10000 -s10000_) = AnoGra.10k

Bedtools nuc function: calculate GC percentage within each window (default settings)

visualized w R circlize package

genome-wide GC-content and SD using BBmap stats fucntion 


## Gene density
Bedtools nuc // will calculate the number of genes within each 10kb window

Use AnoGra.10k and MAKER generated gene models as input

visualized w R circlize package






## mtgenome assembly
don't know if we'll be doing this or not

if so, could use pipeline caden will show me

## chromosome size analysis
do we need to do this or can we use sagrei chromosome sizes?

is there a karyotype available?

## repetative element content
Kimura-2 parameter divergence from consensus

Compare repetitive profiles of grahami to another species of anole

Do this by comparing proportion of assembly comprised of insertions to their divergence from family consensus

RepeatModeler/RepeatMasker

Mask known repeats

Use repeat modeler to find new repeats

## gene model annotation
compare to sagrei

MAKER: Align known protein-coding sequences
SNAP: Gene predictor

## sex chromosome identification
using inbar's analyses

### x chromosome synteny
align x chromosome to related species genomes

## haplotype errors?

## Linkage Disequilibrium maps
LDMAP program

Assesses continuity 

Generate LD maps for each of the contig joins

## population history for species

## Rate of transversions @ 4-fold degenerate sites
determine neutral rate of mutations

## Phylogenetic analyses (Sun 2020)
MCMC

Predict divergence times

## Selection on protein-coding genes
measure selective pressures

Generate MSA (multiple sequence alignment); 
Include sauropsida species

dN/ds - ratio of nonsynonymous/synonymous substitutions








