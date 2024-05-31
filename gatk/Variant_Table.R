#Code used here adapted from: https://evodify.com/gatk-in-non-model-organism/
#Code originally written by Jody Taft and adapted by Alyssa Vanerelli

library('gridExtra')
library('ggplot2')

# Set working directory
setwd("~/Desktop/grahami/gatk:snpeff/")

# Read in data
VCFsnps <- read.csv('DTG-SG-149_snps.table', header = T, na.strings=c("","NA"), sep = "\t") 

VCFindel <- read.csv('DTG-SG-149_indels.table', header = T, na.strings=c("","NA"), sep = "\t")

# Retrieve dimensions of object
dim(VCFsnps)
dim(VCFindel)

# Combine into one file
VCF <- rbind(VCFsnps, VCFindel)

# Add column for variant type
VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))

# Set colors
snps <- '#F4CCCA'
indels <- '#A9E2E4' 

# Make plots

### Depth (DP)

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) +  
  geom_vline(xintercept=c(5,60)) + xlim(0, 200)

### QualByDepth (QD)

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2, size=0.7) 

### Fisherstrand (FS)

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) + xlim(0, 100) + geom_vline(xintercept=c(60), size=0.7)

### StrandOddsRatio (SOR)

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=3, size=1)

### RMSMappingQuality (MQ)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)
# + xlim(0, 75)

### MappingQualityRankSumTest (MQRankSum)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-12.5, size=0.7) + xlim(-25, 25)

### ReadPosRankSumTest (ReadPosRankSum)

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-8, size=1) + xlim(-30, 30)

# Plot graphs and save into one PDF

pdf("DTG-SG-149.pdf")
plot(DP)
plot(QD)
plot(FS)
plot(MQ)
plot(MQRankSum)
plot(SOR)
plot(ReadPosRankSum)
dev.off()
