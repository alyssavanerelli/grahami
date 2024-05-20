```
#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=filter_variants
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/slurmout/slurm-%j-%x.out
#SBATCH --mem=40G
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
module load GATK/4.2.2.0-yc759

echo ""
echo "load variables"
COHORT=$1
INDIR="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf"
GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
OUT_SNP="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/snps"
OUT_INDEL="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/indels"
OUT_INVARIANT="/projects/f_geneva_1/alyssa/sagrei/genotype_gvcf/invariant"



echo ""
echo "Variant Filtration SNPs"
gatk --java-options "-Xmx40g" \
VariantFiltration \
-V ${OUT_SNP}/${COHORT}_snps.vcf.gz \
--filter-expression "QUAL < 0.00 || MQ < 40.00 || SOR > 3.00 || QD < 2.000 || FS > 60.000 || MQRankSum < -12.50 || ReadPosRankSum < -8.00 || ReadPosRankSum > 8.00" \
--filter-name "my_snp_filter" \
-O ${OUT_SNP}/${COHORT}_snps_filtered.vcf.gz

echo ""
echo "Extract passing SNPs"
zcat ${OUT_SNP}/${COHORT}_snps_filtered.vcf.gz | grep -E '^#|PASS' > ${OUT_SNP}/${COHORT}_snps_filtered_passed.vcf



echo ""
echo "Variant Filtration indels"
gatk --java-options "-Xmx40g" \
VariantFiltration \
-V ${OUT_INDEL}/${COHORT}_indels.vcf.gz \
--filter-expression "QUAL < 0.00 || QD < 2.000 || FS > 60.000 || ReadPosRankSum < -8.00 || ReadPosRankSum > 8.00" \
--filter-name "my_indel_filter" \
-O ${OUT_INDEL}/${COHORT}_indels_filtered.vcf.gz

echo ""
echo "Extract passing indels"
zcat ${OUT_INDEL}/${COHORT}_indels_filtered.vcf.gz | grep -E '^#|PASS' > ${OUT_INDEL}/${COHORT}_indels_filtered_passed.vcf



echo ""
echo "Mark quality filtered SNPs"
gatk --java-options "-Xmx40g" \
VariantFiltration \
-R ${GEN_DIR}/AnoSag2.1.fa \
-V ${OUT_SNP}/${COHORT}_snps_filtered_passed.vcf \
-G-filter "DP < 3 || DP > 70" \
-G-filter-name "depth_filter" \
-O ${OUT_SNP}/${COHORT}_snps_filtered_depth.vcf.gz

echo ""
echo "Extract passing SNPs"
zcat ${OUT_SNP}/${COHORT}_snps_filtered_depth.vcf.gz | grep -E '^#|PASS' > ${OUT_SNP}/${COHORT}_snps_filtered_depth_passed.vcf


echo ""
echo "Mark quality filtered indels"
gatk --java-options "-Xmx40g" \
VariantFiltration \
-R ${GEN_DIR}/AnoSag2.1.fa \
-V ${OUT_INDEL}/${COHORT}_indels_filtered_passed.vcf \
-G-filter "DP < 3 || DP > 70" \
-G-filter-name "depth_filter" \
-O ${OUT_INDEL}/${COHORT}_indels_filtered_depth.vcf.gz

echo ""
echo "Extract passing indels"
zcat ${OUT_INDEL}/${COHORT}_indels_filtered_depth.vcf.gz | grep -E '^#|PASS' > ${OUT_INDEL}/${COHORT}_indels_filtered_depth_passed.vcf



echo ""
echo "Mark quality filtered invariants"
gatk --java-options "-Xmx40g" \
VariantFiltration \
-R ${GEN_DIR}/AnoSag2.1.fa \
-V ${OUT_INVARIANT}/${COHORT}_invariants.vcf.gz \
-G-filter "DP < 3 || DP > 70" \
-G-filter-name "depth_filter" \
-O ${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth.vcf.gz

echo ""
echo "Extract passing invariants"
zcat ${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth.vcf.gz | grep -E '^#|PASS' > ${OUT_INVARIANT}/${COHORT}_invariants_filtered_depth_passed.vcf


echo ""
echo "done"
```
