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

## GWAS: association between genomic variation and phenotypic sex
Using the VCF output from the all-samples (82 samples: 41 males, 41 females) ipyrad run. Analysis performed on the first (largest) 20 scaffolds in the assembly. 

```bash
#!/bin/bash

#SBATCH -p shared
#SBATCH --cpus-per-task=4
#SBATCH -N 1
#SBATCH --mem 10G
#SBATCH -t 1-00:00:00
#SBATCH -J grh_sex_gwas
#SBATCH -o grh_sex_gwas_%j.out
#SBATCH -e grh_sex_gwas_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=imaayan@g.harvard.edu

module load Mambaforge/22.11.1-fasrc01

# load singularity image on the cluster which preserves the modules needed to run this script.
singularity run /n/singularity_images/FAS/centos7/compute-el7-noslurm-2023-03-29.sif

# Load modules
#VCFlib
module load vcflib/2015Feb18-fasrc01
#PLINK
module load plink/1.90-fasrc01
#VCFtools
module load vcftools/0.1.14-fasrc01

# input file is grh_G90.vcf

# look at the order of samples, and then make grh_sex.txt file, with a single column where 1 is Male and 2 is Female
vcfsamplenames grh_G90.vcf

#change chromosome label to numeric (vcftools compatibility)
sed -i 's/scaffold_//g' grh_G90.vcf

#keep the first 20 scaffolds
grep "#" grh_G90.vcf > VCF_header.txt
grep -v "#" grh_G90.vcf > grh.txt
awk '$1 <= 20 {print $0}' grh.txt > grh20scf.txt
cat VCF_header.txt grh20scf.txt > grh20scf.vcf

#make PLINK PED and MAP files
vcftools --vcf grh20scf.vcf --plink --out grh20scf


#add sex information as the trait (6th column) in the PED file
cut -f 1-5 grh20scf.ped > grh.first_5_columns.txt
paste grh.first_5_columns.txt grh_sex.txt > grh.first_6_columns.txt
cut -f 7- grh20scf.ped > grh.columns_7_onwards.txt
paste grh.first_6_columns.txt grh.columns_7_onwards.txt > grh.v2.ped
rm grh.first_5_columns.txt grh.first_6_columns.txt grh.columns_7_onwards.txt
mv grh.v2.ped grh20scf.ped

#GWAS for maleness trait
plink --file grh20scf --assoc fisher --noweb --allow-no-sex

#summarize association results for plotting
#keep information on CHR, SNP, BP, and P value
awk '{print $1,$2,$3,$8}' plink.assoc.fisher > grh20scf.assoc.fisher.csv
awk '{a = -log($8)/log(10); printf("%0.4f\n", a)}' plink.assoc.fisher > grh20scf.logp.csv
sed -i 's/+inf/logp/g' grh20scf.logp.csv
paste grh20scf.assoc.fisher.csv grh20scf.logp.csv > grh20scf.gwas_for_plotting.txt
sed -i 's/\t/ /g' grh20scf.gwas_for_plotting.txt

# leave singularity image
exit

# use grh20scg.gwas_for_plotting.txt to plot figure in R

```

