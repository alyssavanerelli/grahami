# next steps
## juicer
- HiC maps - diagonal graph
- Using HiC assembly and reference genome
- Do this to make sure our genome is assembled correctly
- Go to folder to see detailed instructions

## busco phylogenomics
- Will create trimmed alignments of genes present and single copy in genomes for all species used, then infer phylogenies via either concatenation and phylogenetic analysis (IQ-Tree) or by inferring individual gene trees (IQ-TREE) and performing species tree inference (ASTRAL)
- Will download a suite of genomes, run BUSCO on each, run busco_phylogenomics, then visualize with iTOL
- Go to folder for detailed instructions


## satsuma2
- This will compare our chromosome assembly with _Anolis carolinensis_ to assess synteny
- Confirm placement of scaffolds
- Look for evidence of fusion/fission across the genome
- Use R circlize package for visualization of chromosome synteny
- Go to folder for detailed instructions

## GC-content
- This will divide our largest scaffolds into 10kb windows, then calculate GC percentage within each window
- Visualize with R circlize package
- Go to folder for detailed instructions


Bedtools

divide largest scaffolds into 10kb windows (settings _-w10000 -s10000_) = AnoGra.10k

Bedtools nuc function: calculate GC percentage within each window (default settings)

visualized w R circlize package

genome-wide GC-content and SD using BBmap stats fucntion 


## Gene density
- This program will divide our largest scaffolds into 10kb windows, then calculate the number of genes within each window
- Will use MAKER generated models as input
- Visualize with R circlize package
- Go to folder for detailed instructions


Bedtools nuc // will calculate the number of genes within each 10kb window

Use AnoGra.10k and MAKER generated gene models as input

visualized w R circlize package





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








