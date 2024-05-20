#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=combine_allsites
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/allsites/slurmout/slurm-%j-%x.out
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
OUT_ALLSITES="/projects/f_geneva_1/alyssa/sagrei/allsites"


echo ""
echo "copy files"
cp ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf ${OUT_SNP}/${COHORT}_snp_final_filtered.vcf
cp ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf ${OUT_INDEL}/${COHORT}_indels_final_filtered.vcf
cp ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf ${OUT_INVARIANT}/${COHORT}_invariants_final_filtered.vcf

echo ""
echo "bgzip files"
bgzip ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf
bgzip ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf
bgzip ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf


echo ""
echo "index files using tabix"
tabix ${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf.gz
tabix ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf.gz
tabix ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf.gz


echo ""
echo "combine using bcftools"
bcftools concat \
--allow-overlaps \
${OUT_SNP}/${COHORT}_snp_vcftools_filtered.vcf.recode.vcf.gz ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf.gz ${OUT_INVARIANT}/${COHORT}_invariants_vcftools_filtered.vcf.recode.vcf.gz \
-O z -o ${OUT_ALLSITES}/${COHORT}_allsites.vcf.gz


echo ""
echo "index files"
bcftools index -t ${OUT_ALLSITES}/${COHORT}_allsites.vcf.gz

echo ""
echo "done"
