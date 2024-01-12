# Visualizing TADs

## Resources
- [HiCRes](https://github.com/ClaireMarchal/HiCRes): Estimating and predicting HiC library resolution
- [Dovetail TAD info](https://dovetailgenomics.com/wp-content/uploads/2021/09/TADS_appNote.pdf)
- [HiCExplorer GitHub Page](https://github.com/deeptools/HiCExplorer)
- [HiCExplorer Tools](https://hicexplorer.readthedocs.io/en/latest/content/list-of-tools.html)
- [hicPlotMatrix](https://hicexplorer.readthedocs.io/en/latest/content/tools/hicPlotMatrix.html#hicplotmatrix): Creates a heatmap of a Hi-C matrix.
- [hicPlotTADs](https://hicexplorer.readthedocs.io/en/latest/content/tools/hicPlotTADs.html#usage-example): The hicPlotTADs output is similar to a genome browser screenshot that besides the usual genes and score data (like bigwig or bedgraph files) also contains Hi-C data.

---

## Installation
```
conda create --name hicexplorer hicexplorer=3.6 python=3.8 -c bioconda -c conda-forge
conda activate hicexplorer
```

---

## Data

The _grahami_ HiC reads are here: `/projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra/fastq/`

---

## Usage

**Generate a Hi-C contact matrix**
1. Map the Hi-C reads to the reference genome
2. Filter the aligned reads to create a contact matrix
3. Filter matrix bins with low or zero read coverage
4. Remove biases from the Hi-C contact matrices

After a corrected Hi-C matrix is created other tools can be used to visualize it, call TADS or compare it with other matrices.

### Mapping Reads
- Mates have to be mapped individually to avoid mapper specific heuristics designed for standard paired-end libraries.
- We have used the HiCExplorer successfully with `bwa`, `bowtie2`, and `hisat2`. However, it is important to:
  - for either `bowtie2` or `hisat2` use the `–reorder parameter` which tells `bowtie2` or `hisat2` to output the sam files in the exact same order as in the .fastq files.
  - use local mapping, in contrast to end-to-end. A fraction of Hi-C reads are chimeric and will not map end-to-end thus, local mapping is important to increase the number of mapped reads.
  - Tune the aligner parameters to penalize deletions and insertions. This is important to avoid aligned reads with gaps if they happen to be chimeric.
- **bwa mem mapping options:**
  - `-A` INT: score for a sequence match, which scales options -TdBOELU unless overridden `[1]`
  - `-B` INT: penalty for a mismatch `[4]`
  - `-O` INT[,INT]: gap open penalties for deletions and insertions `[6,6]`
  - `-E` INT[,INT]: gap extension penalty; a gap of size k cost `{-O} + {-E}*k` `[1,1]`
    - this is set very high to avoid gaps at restriction sites. Setting the gap extension penalty high, produces better results as the sequences left and right of a restriction site are mapped independently.
  - `-L` INT[,INT]: penalty for 5'- and 3'-end clipping `[5,5]`
    - this is set to no penalty.

[map_reads.sh](https://github.com/alyssavanerelli/grahami/blob/main/analyses/TADs/map_reads.sh)

[run_map_reads.sh](https://github.com/alyssavanerelli/grahami/blob/main/analyses/TADs/run_map_reads.sh)

### Find Restriction Sites
[`hicFindRestSite`](https://hicexplorer.readthedocs.io/en/latest/content/tools/hicFindRestSite.html)

### Create HiC Matrix

- Once the reads have been mapped the Hi-C matrix can be built. 
- For this, the minimal extra information required is the **binSize** used for the matrix. 
  - Is it best to enter a low number like 10,000 because lower resolution matrices (larger bins) can be easily constructed using `hicMergeMatrixBins`
  - Matrices at restriction fragment resolution can be created by providing a file containing the restriction sites, this file can be created with the tool `hicFindRestSites`

[create_matrix.sh](https://github.com/alyssavanerelli/grahami/blob/main/analyses/TADs/create_matrix.sh)










