```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=vcftools_filter_invar
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
INVAR=${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth_passed.vcf

echo ""
echo "set filters for vcftools"
#MAF=0                                    # set Minor Allele Frequency
MISS=0.9                                # set minimum missing data - Here 0.9 means we tolerate 10% missing data
QUAL=30                                  # minimum quality score for a site to pass filtering threshold
MIN_DEPTH=3                              # minimum mean depth and minimum depth allowed for a genotype
MAX_DEPTH=75                           # maximum mean depth and maximum depth allowed for a genotype

echo ""
echo "Run vcftools on invariant sites file"
# ======
# --remove-indels                       # I left this here for just incase downstream

vcftools --vcf ${INVAR} \
--max-missing ${MISS} --minDP ${MIN_DEPTH} --maxDP ${MAX_DEPTH} \
--min-meanDP ${MIN_DEPTH} --max-meanDP ${MAX_DEPTH} \
--recode --recode-INFO-all --out ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf 

#| bgzip -c > $1_INVARIANT_depth_filterPASSED_0.25max_missing.vcf.gz
	
echo ""
echo "done"
```
