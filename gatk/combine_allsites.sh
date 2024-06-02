#!/bin/bash
#SBATCH --partition=cmain
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=combine_allsites
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
OUT_ALLSITES="/projects/f_geneva_1/alyssa/grahami/gatk/allsites"


echo ""
echo "copy files"
cp ${OUT_SNP}/${SAMPLE}_snp_vcftools_filtered.vcf.recode.vcf ${OUT_SNP}/${SAMPLE}_snp_final_filtered.vcf
cp ${OUT_INDEL}/${SAMPLE}_indels_filtered_depth_passed.vcf ${OUT_INDEL}/${SAMPLE}_indels_final_filtered.vcf
cp ${OUT_INVARIANT}/${SAMPLE}_invariants_vcftools_filtered.vcf.recode.vcf ${OUT_INVARIANT}/${SAMPLE}_invariants_final_filtered.vcf

echo ""
echo "bgzip files"
bgzip ${OUT_SNP}/${SAMPLE}_snp_final_filtered.vcf
bgzip ${OUT_INDEL}/${SAMPLE}_indels_final_filtered.vcf
bgzip ${OUT_INVARIANT}/${SAMPLE}_invariants_final_filtered.vcf


echo ""
echo "index files using tabix"
tabix ${OUT_SNP}/${SAMPLE}_snp_final_filtered.vcf.gz
tabix ${OUT_INDEL}/${SAMPLE}_indels_final_filtered.vcf.gz
tabix ${OUT_INVARIANT}/${SAMPLE}_invariants_final_filtered.vcf.gz


echo ""
echo "combine using bcftools"
bcftools concat \
--allow-overlaps \
${OUT_SNP}/${SAMPLE}_snp_final_filtered.vcf.gz ${OUT_INDEL}/${SAMPLE}_indels_final_filtered.vcf.gz ${OUT_INVARIANT}/${SAMPLE}_invariants_final_filtered.vcf.gz \
-O z -o ${OUT_ALLSITES}/${SAMPLE}_allsites.vcf.gz


echo ""
echo "index files"
bcftools index -t ${OUT_ALLSITES}/${SAMPLE}_allsites.vcf.gz

echo ""
echo "done"
