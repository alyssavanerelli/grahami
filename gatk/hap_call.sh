#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=gatk_HC
#SBATCH --output=/projects/f_geneva_1/alyssa/sagrei/haplotype_caller/slurmout/slurm-%j-%x.out
#SBATCH --mem=75G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=14-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=av795@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load GATK/4.2.2.0-yc759
module load samtools


echo ""
echo "load variables"
SAMPLE=$1
INDIR="/projects/f_geneva_1/alyssa/sagrei/mark_duplicates"
GEN_DIR="/projects/f_geneva_1/alyssa/sagrei/genome"
OUTDIR="/projects/f_geneva_1/alyssa/sagrei/haplotype_caller"
SCRATCH_DIR="/scratch/av795"


echo ""
echo "run haplotype caller"
gatk --java-options "-Xms75G -Xmx75g -XX:ParallelGCThreads=2" HaplotypeCaller --native-pair-hmm-threads 2 \
-I ${INDIR}/${SAMPLE}.marked.bam \
-O ${OUTDIR}/${SAMPLE}.g.vcf.gz \
-R ${GEN_DIR}/AnoSag2.1.fa \
-ERC GVCF \
--max-reads-per-alignment-start 0 \
-RF NotDuplicateReadFilter


echo ""
echo "done"



#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=gatk_HC_split_1
#SBATCH --mem=50G
#SBATCH -n 2
#SBATCH -N 1
#SBATCH --time=5-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=chf29@scarletmail.rutgers.edu
#SBATCH --mail-type=FAIL,END


echo "load modules"
module purge
module use /projects/community/modulefiles/
module load java
module load GATK/4.2.2.0-yc759
module load samtools


echo ""
echo "load variables"
SAMPLE=$1
INDIR="/projects/f_geneva_1/chfal/distichus/gatk_pipeline/haplotype_caller"
GEN_DIR="/projects/f_geneva_1/chfal/distichus/gatk_pipeline/haplotype_caller"
OUTDIR="/projects/f_geneva_1/chfal/distichus/gatk_pipeline/haplotype_caller"

echo ""
echo "run haplotype caller"
gatk --java-options "-Xms50G -Xmx50g -XX:ParallelGCThreads=2" HaplotypeCaller --native-pair-hmm-threads 2 \
-I ${INDIR}/${SAMPLE}.marked.bam \
-O ${OUTDIR}/${SAMPLE}.1.g.vcf.gz \
-R ${GEN_DIR}/AnoDis1.0.fasta \
-ERC BP_RESOLUTION \
--output-mode EMIT_ALL_CONFIDENT_SITES \
--max-reads-per-alignment-start 0 \
-RF NotDuplicateReadFilter \
-L ${GEN_DIR}/scaffold_1.list


#--exclude=halc068
#--exclude=gpuc001,gpuc002

echo ""
echo "done"
