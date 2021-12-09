# Installing Juicer

[Official GitHub](https://github.com/aidenlab/juicer/wiki)

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
  - `references`
    - copy over references file here as well
  - `scripts`
    - soft link scripts folder here as well
    - `ln -s ../juicer/SLURM/scripts/ scripts`

### Example
```
cd /projects/f_geneva_1/alyssa/grahami
mkdir juicerdir                                           #this is where i will complete all my juicer analyses
cd juicerdir

mkdir references
cp ../../AnoGra1.1.fa references/                         #copying my final assembly (in FASTA format) to the references directory

git clone https://github.com/theaidenlab/juicer.git       #this will download all the juicer scripts to a directory `juicer/`
ln -s juicer/SLURM/scripts/ scripts                       #this will make a directory `scripts/` in my original `juicerdir/` directory containing only the SLURM scripts

cd scripts
wget https://s3.amazonaws.com/hicfiles.tc4ga.com/public/juicer/juicer_tools_1.22.01.jar       #downloading the most recent version of juicer tools jar
ln -s juicer_tools_1.22.01.jar juicer_tools.jar           #creating a file juicer_tools.jar that links to this version

cd ..
mkdir AnoGra                                              #making my working directory for Anolis grahami
mkdir fastq                                               #directory where fastq HiC reads will go
```

# Running Juicer on the cluster
_modules that will need to be loaded: cuda/8.0 and java/1.8.0_252_

1. `juicerdir/AnoGra/references/` directory
   - make sure to copy reference genome for your species to this folder
   - BWA index this reference

```
module purge                                    # clears out any pre-existing modules
module load samtools                            # load any modules needed
module load bwa

bwa index /projects/f_geneva_1/alyssa/grahami/juicerdir/references/AnoGra1.1.fa

samtools faidx /projects/f_geneva_1/alyssa/grahami/juicerdir/references/AnoGra1.1.fa
```

2. Create a file only containing your genome scaffold names and sizes

```
cut -f1-2 AnoGra1.1.fa.fai > AnoGra1.1.chrom.sizes
```

3. You should have a working directory `juicerdir/AnoGra/` that contains `fastq/`
   - fastq reads (zipped or unzipped) should be either copied or soft-linked to this folder


**What should be in your working directory folders at this stage, complete before running juicer**
- `AnoGra`
  - `fastq`
    - HiC R1 and R2 reads ONLY
  - `references`
    - genome file: `AnoGra1.1.fa`
    - scaffold sizes file: `AnoGra1.1.chrom.sizes`
    - bwa and samtools indexed files ending in: amb, ann, bwt, fai, pac, sa

_anything else (e.g. bwa index slurm file, slurm output file, etc.) needs to be stored elsewhere. I moved these to the larger `juicerdir` folder_



4. Type `screen` then launch Juicer:

```
/projects/f_geneva_1/alyssa/grahami/juicedir/scripts/juicer.sh [options]
```
[options](https://github.com/aidenlab/juicer/wiki/Usage) for juicer

**code specific to _Anolis grahami_**

```
screen              # this will launch Juicer
module load cuda/8.0
module load java/1.8.0_252



./scripts/juicer.sh -g AnoGra1.1 -d /projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra -p /projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra/references/AnoGra1.1.fa.chrom.sizes -y none -z /projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra/references/AnoGra1.1.fa -D /projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra -t 20 -q p_ccib_1 -l p_ccib_1
```



# Juicer Results

Results will be contained in the `aligned/` folder in your working directory (e.g., `AnoGra/`)
- **inter.hic / inter_30.hic**: The .hic files for Hi-C contacts at MAPQ > 0 and at MAPQ >= 30, respectively
- **merged_nodups.txt**: The Hi-C contacts with duplicates removed. This file is also input to the assembly and diploid pipelines
- **collisions.txt**: Reads that map to more than two places in the genome
- **inter.txt, inter_hists.m / inter_30.txt, inter_30_hists.m**: The statistics and graphs files for Hi-C contacts at MAPQ > 0 and at MAPQ >= 30, respectively. These are also stored within the respective .hic files in the header. The .m files can be loaded into Matlab. The statistics and graphs are displayed under Dataset Metrics when loaded into Juicebox
- **dups.txt, opt_dups.txt**: Duplicates and optical duplicates
- **abnormal.sam, unmapped.sam**: Abnormal chimeric and unmapped reads
- **merged_sort.txt**: This is a combination of merged_nodups / dups / opt_dups and can be deleted once the pipeline has successfully completed
- **stats_dups.txt / stats_dups_hists.m**: Statistics and graphs on the duplicates

`splits` is a temporary working directory and can be deleted once you are sure the pipeline ran successfully

`debug` contains logging information for the pipeline

You should run the script `cleanup.sh` to zip all the text files and delete the unnecessary `splits` directory and `merged_sort.txt` file once you are sure the pipeline has successfully completed


# Viewing Results

`.hic` results can be loaded into [Juicebox](https://github.com/aidenlab/Juicebox/wiki)












