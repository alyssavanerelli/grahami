# HiC Explorer
[HiCExplorer](https://hicexplorer.readthedocs.io/en/latest/)

Following [this tutorial](https://hicexplorer.readthedocs.io/en/latest/content/example_usage.html)

## Installation
```
conda create --name hicexplorer hicexplorer=3.6 python=3.8 -c bioconda -c conda-forge
```

## Map the Hi-C reads to the reference genome
- Using `bwa`
- Mates have to be mapped individually to avoid mapper specific heuristics designed for standard paired-end libraries
- It is important to:
  - Use local mapping, in contrast to end-to-end. A fraction of Hi-C reads are chimeric and will not map end-to-end thus, local mapping is important to increase the number of mapped reads
  - Tune the aligner parameters to penalize deletions and insertions. This is important to avoid aligned reads with gaps if they happen to be chimeric

Create symlinks for your HiC reads using [run_softlink.sh](https://github.com/alyssavanerelli/grahami/blob/main/hicexplorer/run_softlink.sh)

[map_reads.sh](https://github.com/alyssavanerelli/grahami/blob/main/hicexplorer/map_reads.sh)


## Create HiC matrix
- Once the reads have been mapped the Hi-C matrix can be built
- The minimal extra information required is the `binSize` used for the matrix
  - Is it best to enter a low number like `10.000` because lower resolution matrices (larger bins) can be easily constructed using `hicMergeMatrixBins`
- Matrices at restriction fragment resolution can be created by providing a file containing the restriction sites, this file can be created with the tool `hicFindRestSites`


```
# build matrix from independently mated read pairs
# the restriction sequence GATC is recognized by the DpnII restriction enzyme

$ hicBuildMatrix --samFiles mate_R1.bam mate_R2.bam \
                 --binSize 10000 \
                 --restrictionSequence GATC \
                 --danglingSequence GATC \
                 --restrictionCutFile cut_sites.bed \
                 --threads 4 \
                 --inputBufferSize 100000 \
                 --outBam hic.bam \
                 -o hic_matrix.h5 \
                 --QCfolder ./hicQC
```

- hicBuildMatrix creates two files, a bam file containing only the valid Hi-C read pairs and a matrix containing the Hi-C contacts at the given resolution
- The bam file is useful to check the quality of the Hi-C library on the genome browser
- A good Hi-C library should contain piles of reads near the restriction fragment sites
- In the `QCfolder` a html file is saved with plots containing useful information for the quality control of the Hi-C sample like the number of valid pairs, duplicated pairs, self-ligations etc
- Usually, only 25%-40% of the reads are valid and used to build the Hi-C matrix mostly because of the reads that are on repetitive regions that need to be discarded
- An important quality control measurement to check is the inter chromosomal fraction of reads as this is an indirect measure of random Hi-C contacts
  - Good Hi-C libraries have lower than 10% inter chromosomal contacts
  - The `hicQC` module can be used to compare the QC measures from different samples



## Correct HiC matrix
- The Hi-C matrix has to be corrected to remove GC, open chromatin biases and, most importantly, to normalize the number of restriction sites per bin
- Because a fraction of bins from repetitive regions contain few contacts it is necessary to filter those regions first
- Also, in mammalian genomes some regions enriched by reads should be discarded
- To aid in the filtering of regions `hicCorrectMatrix` generates a diagnostic plot

```
$ hicCorrectMatrix diagnostic_plot -m hic_matrix.h5 -o hic_corrected.png
```

- For the upper threshold is only important to remove very high outliers and thus a value of 5 could be used
- For the lower threshold it is recommended to use a value between -2 and -1
- What it not desired is to try to correct low count bins which could result simply in an amplification of noise
- For the upper threshold is not so concerning because those bins will be scaled down
- Once the thresholds have been decided, the matrix can be corrected

```
# correct Hi-C matrix
$ hicCorrectMatrix correct -m hic_matrix.h5 --filterThreshold -1.5 5 -o hic_corrected.h5
```

- In the case of multiple samples / replicates that need to be normalized to the same read coverage we recommend to compute first the normalization (with hicNormalize) and correct the data (with hicCorrectMatrix) in a second step


## Visualize results
- There are two ways to see the resulting matrix, one using `hicPlotMatrix` and the other is using `hicPlotTADs`
- The first one allows the visualization over large regions while the second one is preferred to see specific parts together with other information, for example genes or bigwig tracks
- Because of the large differences in counts found int he matrix, it is better to plot the counts using the –log1p option.

```
$ hicPlotMatrix -m hic_corrected.h5 -o hic_plot.png --region 1:20000000-80000000 --log1p
```






