# Installing Juicer

## Make sure dependencies are installed
- For alignment and creation of the Hi-C pairs file `merged_nodups.txt`
  - [GNU CoreUtils](https://www.gnu.org/software/coreutils/manual/)
  - [Burrows-Wheeler Aligner (BWA)](http://bio-bwa.sourceforge.net/)
- For .hic file creation and [Juicer tools analysis](https://github.com/aidenlab/juicer/wiki/Feature-Annotation)
  - [Java 1.7 or 1.8](https://www.oracle.com/java/technologies/downloads/#java8)
  - [Latest Juicer Tools jar](https://github.com/aidenlab/juicer/wiki/Download)
- For peak calling
  - [CUDA](https://developer.nvidia.com/cuda-downloads)
  - The native libraries included with Juicer are compiled for CUDA 7. Other versions of CUDA can be used, but you will need to download the respective native libraries from [JCuda](https://developer.nvidia.com/cuda-downloads).


## Set up directories
You should have Juicer directory containing `scripts/`, `references/` (and optionally `restriction_sites/`), and a different working directory `AnoGra/` containing `fastq/`

[Juicer Tools jar](https://github.com/aidenlab/juicer/wiki/Download) should be installed in your `scripts/` directory

### Directory explanations
- `scripts/`
  - this folder contains SLURM scripts downloaded with a link provided below
- `references/`
  - this folder contains your reference genome and the BWA index files
- `AnoGra/`
  - this is your working directory
  - `fastq/`
    - this contains your sequence HiC reads and can remained zipped
