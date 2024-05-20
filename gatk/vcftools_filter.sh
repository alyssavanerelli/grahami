```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=vcftools_filter_snp
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
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
COHORT=$1
INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"
SNPS=${OUT_SNP}/${COHORT}_snps_filtered_depth_passed.vcf

echo ""
echo "Set filters for vcftools"
MAF=0                                    # set Minor Allele Frequency
MISS=0.9                                # set minimum missing data - Here 0.9 means we tolerate 10% missing data
QUAL=30                                  # minimum quality score for a site to pass filtering threshold
MIN_DEPTH=3                              # minimum mean depth and minimum depth allowed for a genotype
MAX_DEPTH=75                           # maximum mean depth and maximum depth allowed for a genotype

echo ""
echo "Run vcftools"
# ======
# --remove-indels                       # I left this here for just incase downstream

vcftools --vcf ${SNPS} \
--maf ${MAF} --max-missing ${MISS} --minQ ${QUAL} \
--min-meanDP ${MIN_DEPTH} --max-meanDP ${MAX_DEPTH} \
--minDP ${MIN_DEPTH} --maxDP ${MAX_DEPTH} --recode --out ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf
		
echo ""
echo "done"
```
