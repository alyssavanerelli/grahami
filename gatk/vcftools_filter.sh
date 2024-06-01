#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=vcftools_filter_snp
#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/gatk/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load VCFtools/vcftools-v0.1.16-13-yc759

echo ""
echo "load variables"
#SAMPLE=$1
SAMPLE='DTG-SG-149'
INDIR="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/grahami"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf"
BASE_DIR='/projects/f_geneva_1/alyssa/grahami/gatk'
OUT_SNP="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/snps"
OUT_INDEL="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/indels"
OUT_INVARIANT="/projects/f_geneva_1/alyssa/grahami/gatk/genotype_gvcf/invariant"
SNPS=${OUT_SNP}/${SAMPLE}_snps_filtered_depth_passed.vcf

echo ""
echo "Set filters for vcftools"
MAF=0                                    # set Minor Allele Frequency
#MISS=0.9                                # set minimum missing data - Here 0.9 means we tolerate 10% missing data
QUAL=30                                  # minimum quality score for a site to pass filtering threshold
MIN_DEPTH=3                              # minimum mean depth and minimum depth allowed for a genotype
MAX_DEPTH=100                           # maximum mean depth and maximum depth allowed for a genotype

echo ""
echo "Run vcftools"
# ======
# --remove-indels                       # I left this here for just incase downstream

vcftools --vcf ${SNPS} \
--maf ${MAF} --minQ ${QUAL} \
--min-meanDP ${MIN_DEPTH} --max-meanDP ${MAX_DEPTH} \
--minDP ${MIN_DEPTH} --maxDP ${MAX_DEPTH} --recode --out ${OUT_SNP}/${SAMPLE}_snp_vcftools_filtered.vcf

#--max-missing ${MISS}

echo ""
echo "done"
