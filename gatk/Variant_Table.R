#Code used here adapted from: https://evodify.com/gatk-in-non-model-organism/
#Code written by Jody Taft and adapted by Alyssa Vanerelli for sagrei data

library('gridExtra')
library('ggplot2')

# Set working directory
setwd("~/Library/CloudStorage/Dropbox/Harvard/sagrei_Pop_Genomics/GATK")



# Alut --------------------------------------------------------------------

#... Generating plots of GATK VariantsToTable Output...#
VCFsnps <- read.csv('Alut_snps.table', header = T, na.strings=c("","NA"), sep = "\t") 

## checking filtered table (need to do variant table again on filtered snp file)

VCFindel <- read.csv('Alut_indels.table', header = T, na.strings=c("","NA"), sep = "\t")

#retrieve dimensions of object
dim(VCFsnps)
dim(VCFindel)

VCF <- rbind(VCFsnps, VCFindel)
#VCF <- rbind(VCFsnps_asag)

VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))
#VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps_asag)[1])))

snps <- '#F4CCCA'
indels <- '#A9E2E4' 

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) +  
  geom_vline(xintercept=c(5,60)) + xlim(0, 200)

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2, size=0.7) 

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) + xlim(0, 100) + geom_vline(xintercept=c(60), size=0.7)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)
# + xlim(0, 75)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-12.5, size=0.7) + xlim(-25, 25)

# Some functions are commented out as they incorporate the indel code as well - adapt as needed

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=3, size=1)

#SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
#  geom_vline(xintercept=c(3, 10), size=1)
#, colour = c(snps))

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-8, size=1) + xlim(-30, 30)

#ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) + xlim(-30, 30) +
#  geom_vline(xintercept=-8, size=1)
 
pdf("Alut.pdf")
plot(DP)
plot(QD)
plot(FS)
plot(MQ)
plot(MQRankSum)
plot(SOR)
plot(ReadPosRankSum)
dev.off()


# Anel --------------------------------------------------------------------
VCFsnps <- NULL
VCFindel <- NULL


VCFsnps <- read.csv('Anel_snps.table', header = T, na.strings=c("","NA"), sep = "\t") 
VCFindel <- read.csv('Anel_indels.table', header = T, na.strings=c("","NA"), sep = "\t")

#retrieve dimensions of object
dim(VCFsnps)
dim(VCFindel)

VCF <- rbind(VCFsnps, VCFindel)
#VCF <- rbind(VCFsnps_asag)

VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))
#VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps_asag)[1])))

snps <- '#F4CCCA'
indels <- '#A9E2E4' 

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) +  
  geom_vline(xintercept=c(5,60)) + xlim(0, 200)

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2, size=0.7) 

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) + xlim(0, 100) + geom_vline(xintercept=c(60), size=0.7)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)
# + xlim(0, 75)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-12.5, size=0.7) + xlim(-25, 25)

# Some functions are commented out as they incorporate the indel code as well - adapt as needed

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=3, size=1)

#SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
#  geom_vline(xintercept=c(3, 10), size=1)
#, colour = c(snps))

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-8, size=1) + xlim(-30, 30)

#ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) + xlim(-30, 30) +
#  geom_vline(xintercept=-8, size=1)

pdf("Anel.pdf")
plot(DP)
plot(QD)
plot(FS)
plot(MQ)
plot(MQRankSum)
plot(SOR)
plot(ReadPosRankSum)
dev.off()



# Asag --------------------------------------------------------------------
VCFsnps <- NULL
VCFindel <- NULL
VCFsnps <- read.csv('Asag_snps.table', header = T, na.strings=c("","NA"), sep = "\t") 
VCFindel <- read.csv('Asag_indels.table', header = T, na.strings=c("","NA"), sep = "\t")

#retrieve dimensions of object
dim(VCFsnps)
dim(VCFindel)

VCF <- rbind(VCFsnps, VCFindel)
#VCF <- rbind(VCFsnps_asag)

VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))
#VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps_asag)[1])))

snps <- '#F4CCCA'
indels <- '#A9E2E4' 

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) +  
  geom_vline(xintercept=c(5,60)) + xlim(0, 200)

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2, size=0.7) 

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) + xlim(0, 100) + geom_vline(xintercept=c(60), size=0.7)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)
# + xlim(0, 75)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-12.5, size=0.7) + xlim(-25, 25)

# Some functions are commented out as they incorporate the indel code as well - adapt as needed

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=3, size=1)

#SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
#  geom_vline(xintercept=c(3, 10), size=1)
#, colour = c(snps))

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-8, size=1) + xlim(-30, 30)

#ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) + xlim(-30, 30) +
#  geom_vline(xintercept=-8, size=1)

pdf("Asag.pdf")
plot(DP)
plot(QD)
plot(FS)
plot(MQ)
plot(MQRankSum)
plot(SOR)
plot(ReadPosRankSum)
dev.off()

# Asmay -------------------------------------------------------------------
VCFsnps <- NULL
VCFindel <- NULL
VCFsnps <- read.csv('Asmay_snps.table', header = T, na.strings=c("","NA"), sep = "\t") 
VCFindel <- read.csv('Asmay_indels.table', header = T, na.strings=c("","NA"), sep = "\t")

#retrieve dimensions of object
dim(VCFsnps)
dim(VCFindel)

VCF <- rbind(VCFsnps, VCFindel)
#VCF <- rbind(VCFsnps_asag)

VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))
#VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps_asag)[1])))

snps <- '#F4CCCA'
indels <- '#A9E2E4' 

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) +  
  geom_vline(xintercept=c(5,60)) + xlim(0, 200)

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2, size=0.7) 

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) + xlim(0, 100) + geom_vline(xintercept=c(60), size=0.7)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)
# + xlim(0, 75)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-12.5, size=0.7) + xlim(-25, 25)

# Some functions are commented out as they incorporate the indel code as well - adapt as needed

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=3, size=1)

#SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
#  geom_vline(xintercept=c(3, 10), size=1)
#, colour = c(snps))

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-8, size=1) + xlim(-30, 30)

#ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) + xlim(-30, 30) +
#  geom_vline(xintercept=-8, size=1)

pdf("Asmay.pdf")
plot(DP)
plot(QD)
plot(FS)
plot(MQ)
plot(MQRankSum)
plot(SOR)
plot(ReadPosRankSum)
dev.off()

# Asord -------------------------------------------------------------------
VCFsnps <- NULL
VCFindel <- NULL
VCFsnps <- read.csv('Asord_snps.table', header = T, na.strings=c("","NA"), sep = "\t") 
VCFindel <- read.csv('Asord_indels.table', header = T, na.strings=c("","NA"), sep = "\t")

#retrieve dimensions of object
dim(VCFsnps)
dim(VCFindel)

VCF <- rbind(VCFsnps, VCFindel)
#VCF <- rbind(VCFsnps_asag)

VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps)[1]), rep("Indels", dim(VCFindel)[1])))
#VCF$Variant <- factor(c(rep("SNPs", dim(VCFsnps_asag)[1])))

snps <- '#F4CCCA'
indels <- '#A9E2E4' 

DP <- ggplot(VCF, aes(x=DP, fill=Variant)) + geom_density(alpha=0.3) +  
  geom_vline(xintercept=c(5,60)) + xlim(0, 200)

QD <- ggplot(VCF, aes(x=QD, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=2, size=0.7) 

FS <- ggplot(VCF, aes(x=FS, fill=Variant)) + geom_density(alpha=.3) + xlim(0, 100) + geom_vline(xintercept=c(60), size=0.7)

MQ <- ggplot(VCF, aes(x=MQ, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=40, size=0.7)
# + xlim(0, 75)

MQRankSum <- ggplot(VCF, aes(x=MQRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-12.5, size=0.7) + xlim(-25, 25)

# Some functions are commented out as they incorporate the indel code as well - adapt as needed

SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=3, size=1)

#SOR <- ggplot(VCF, aes(x=SOR, fill=Variant)) + geom_density(alpha=.3) +
#  geom_vline(xintercept=c(3, 10), size=1)
#, colour = c(snps))

ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) +
  geom_vline(xintercept=-8, size=1) + xlim(-30, 30)

#ReadPosRankSum <- ggplot(VCF, aes(x=ReadPosRankSum, fill=Variant)) + geom_density(alpha=.3) + xlim(-30, 30) +
#  geom_vline(xintercept=-8, size=1)

pdf("Asord.pdf")
plot(DP)
plot(QD)
plot(FS)
plot(MQ)
plot(MQRankSum)
plot(SOR)
plot(ReadPosRankSum)
dev.off()
