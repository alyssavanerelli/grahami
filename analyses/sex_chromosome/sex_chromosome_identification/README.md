# Using ddRAD-Seq data from wild _A. grahami_ to localize the putative sex determining region of the genome

Final sample dataset includes 41 males and 41 females from across 33 sites

## 1. Run ipyrad 
Using sequence data following initial processing (clone_filter, trimming with Trimmomatic, process_radtags)

Running ipyrad with all samples together will output the VCF needed for the GWAS. Running ipyrad for males and females separately will output the VCFs needed for sex-associated read depth analysis. 

```bash
#!/bin/bash

#SBATCH -p shared
#SBATCH --cpus-per-task=16
#SBATCH -N 1
#SBATCH --mem 60G
#SBATCH -t 3-00:00:00
#SBATCH -J ipyrad_grh
#SBATCH -o ipyrad_grh_%j.out
#SBATCH -e ipyrad_grh_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=imaayan@g.harvard.edu

module load Mambaforge/22.11.1-fasrc01
source activate ipyrad

cd /n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad

# run steps 1-7 at 90% (Min # samples per locus for output = 0.9*82)
ipyrad -p params-grh_G90.txt -s 1234567 -c ${SLURM_CPUS_PER_TASK} -f -d

# this will produce, among other files, a vcf file. This file will be used for the GWAS.

# run steps 1-7 at 90% for females and males separately (Min # samples per locus for output = 0.9*41)
ipyrad -p params-grh_G90_F.txt -s 1234567 -c ${SLURM_CPUS_PER_TASK} -f -d
ipyrad -p params-grh_G90_M.txt -s 1234567 -c ${SLURM_CPUS_PER_TASK} -f -d

# this will produce the VCF files for the read depth plot.
```


Parameters used for all-samples run of ipyrad:
```
------- ipyrad params file-------------------------------------------
grh_G90                                                                        ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad                ## [1] [project_dir]: Project dir (made in curdir if not present)
                                                                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
                                                                               ## [3] [barcodes_path]: Location of barcodes file
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_reads/grh*.fq          ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted, unzipped fastq files
reference                                                                       ## [5] [assembly_method]: Assembly method (denovo, reference)
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad/AnoGra1.1.fa    ## [6] [reference_sequence]: Location of reference sequence file
pairddrad                                                                       ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
AATTC, GCATG                                                                    ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                                                                               ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                                                                              ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
6                                                                               ## [11] [mindepth_statistical]: Min depth for statistical base calling
6                                                                               ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                                                                           ## [13] [maxdepth]: Max cluster depth within samples
0.88                                                                            ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                                                                               ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
0                                                                               ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                                                                              ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                                                                               ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
0.1                                                                             ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus
0.1                                                                             ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus
74                                                                              ## [21] [min_samples_locus]: Min # samples per locus for output (90% of 82)
0.25                                                                            ## [22] [max_SNPs_locus]: Max # SNPs per locus
8                                                                               ## [23] [max_Indels_locus]: Max # of indels per locus
0.5                                                                             ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus
0, 0, 0, 0                                                                      ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                                                                      ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
*                                                                               ## [27] [output_formats]: Output formats (see docs)
                                                                                ## [28] [pop_assign_file]: Path to population assignment file
                                                                                ## [29] [reference_as_filter]: Reads mapped to this reference are removed in step 3
```

Parameters used for female-only samples run:
```
------- ipyrad params file (v.0.9.90)-------------------------------------------
grh_G90_F                                                                        ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad                ## [1] [project_dir]: Project dir (made in curdir if not present)
                                                                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
                                                                               ## [3] [barcodes_path]: Location of barcodes file
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_reads/females/grh*.fq          ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted, unzipped fastq files
reference                                                                       ## [5] [assembly_method]: Assembly method (denovo, reference)
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad/AnoGra1.1.fa    ## [6] [reference_sequence]: Location of reference sequence file
pairddrad                                                                       ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
AATTC, GCATG                                                                    ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                                                                               ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                                                                              ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
6                                                                               ## [11] [mindepth_statistical]: Min depth for statistical base calling
6                                                                               ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                                                                           ## [13] [maxdepth]: Max cluster depth within samples
0.88                                                                            ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                                                                               ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
0                                                                               ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                                                                              ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                                                                               ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
0.1                                                                             ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus
0.1                                                                             ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus
37                                                                              ## [21] [min_samples_locus]: Min # samples per locus for output (90% of 82)
0.25                                                                            ## [22] [max_SNPs_locus]: Max # SNPs per locus
8                                                                               ## [23] [max_Indels_locus]: Max # of indels per locus
0.5                                                                             ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus
0, 0, 0, 0                                                                      ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                                                                      ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
*                                                                               ## [27] [output_formats]: Output formats (see docs)
                                                                                ## [28] [pop_assign_file]: Path to population assignment file
                                                                                ## [29] [reference_as_filter]: Reads mapped to this reference are removed in step 3
```


Parameters used for male-only samples run:
```
------- ipyrad params file (v.0.9.90)-------------------------------------------
grh_G90_M                                                                        ## [0] [assembly_name]: Assembly name. Used to name output directories for assembly steps
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad                ## [1] [project_dir]: Project dir (made in curdir if not present)
                                                                               ## [2] [raw_fastq_path]: Location of raw non-demultiplexed fastq files
                                                                               ## [3] [barcodes_path]: Location of barcodes file
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_reads/males/grh*.fq          ## [4] [sorted_fastq_path]: Location of demultiplexed/sorted, unzipped fastq files
reference                                                                       ## [5] [assembly_method]: Assembly method (denovo, reference)
/n/holyscratch01/losos_lab/Users/imaayan/grahami_sex/grh_ipyrad/AnoGra1.1.fa    ## [6] [reference_sequence]: Location of reference sequence file
pairddrad                                                                       ## [7] [datatype]: Datatype (see docs): rad, gbs, ddrad, etc.
AATTC, GCATG                                                                    ## [8] [restriction_overhang]: Restriction overhang (cut1,) or (cut1, cut2)
5                                                                               ## [9] [max_low_qual_bases]: Max low quality base calls (Q<20) in a read
33                                                                              ## [10] [phred_Qscore_offset]: phred Q score offset (33 is default and very standard)
6                                                                               ## [11] [mindepth_statistical]: Min depth for statistical base calling
6                                                                               ## [12] [mindepth_majrule]: Min depth for majority-rule base calling
10000                                                                           ## [13] [maxdepth]: Max cluster depth within samples
0.88                                                                            ## [14] [clust_threshold]: Clustering threshold for de novo assembly
0                                                                               ## [15] [max_barcode_mismatch]: Max number of allowable mismatches in barcodes
0                                                                               ## [16] [filter_adapters]: Filter for adapters/primers (1 or 2=stricter)
35                                                                              ## [17] [filter_min_trim_len]: Min length of reads after adapter trim
2                                                                               ## [18] [max_alleles_consens]: Max alleles per site in consensus sequences
0.1                                                                             ## [19] [max_Ns_consens]: Max N's (uncalled bases) in consensus
0.1                                                                             ## [20] [max_Hs_consens]: Max Hs (heterozygotes) in consensus
37                                                                              ## [21] [min_samples_locus]: Min # samples per locus for output (90% of 82)
0.25                                                                            ## [22] [max_SNPs_locus]: Max # SNPs per locus
8                                                                               ## [23] [max_Indels_locus]: Max # of indels per locus
0.5                                                                             ## [24] [max_shared_Hs_locus]: Max # heterozygous sites per locus
0, 0, 0, 0                                                                      ## [25] [trim_reads]: Trim raw read edges (R1>, <R1, R2>, <R2) (see docs)
0, 0, 0, 0                                                                      ## [26] [trim_loci]: Trim locus edges (see docs) (R1>, <R1, R2>, <R2)
*                                                                               ## [27] [output_formats]: Output formats (see docs)
                                                                                ## [28] [pop_assign_file]: Path to population assignment file
                                                                                ## [29] [reference_as_filter]: Reads mapped to this reference are removed in step 3
```


