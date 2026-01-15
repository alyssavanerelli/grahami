library(tidyverse)
library(readxl)

#input files
GWAS<-read.csv(file="~/Library/CloudStorage/Dropbox/in_progress_papers/grahami_genome_ms/sex_analysis/grh_11_12_GWAS.csv", header=TRUE)
dp<-read.csv(file="~/Library/CloudStorage/Dropbox/in_progress_papers/grahami_genome_ms/sex_analysis/grh_11_12_DPratio.csv", header=TRUE)
intervals <- read.table("~/Library/CloudStorage/Dropbox/in_progress_papers/grahami_genome_ms/sex_analysis/2Mb_50kb_step_windows.bed", header=TRUE)
# Asag X genes
AgraX_genes <- read.table("~/Library/CloudStorage/Dropbox/in_progress_papers/grahami_genome_ms/sex_analysis/Agra_X_orthologs.tsv", header=T)

#depth
lowerq_dp = quantile(dp$DP_ratio,na.rm = TRUE) [2]
upperq_dp = quantile(dp$DP_ratio,na.rm = TRUE) [4]
iqr_dp = upperq_dp - lowerq_dp
mild.threshold.upper_dp = (iqr_dp * 1.5) + upperq_dp
mild.threshold.lower_dp = lowerq_dp - (iqr_dp * 1.5)

#manhattan plot genomewide using ggplot2 (code adapted from https://danielroelfs.com/blog/how-i-create-manhattan-plots-using-ggplot/)
#only chromosomes 1-10 are used for plotting
#the genomewide significance threshold is set using the complete set of 120967 SNPs from all chromosomes
library(dplyr)
library(ggplot2)

nCHR <- length(unique(GWAS$CHR))
GWAS$BPcum <- NA
s <- 0
nbp <- c()
for (i in unique(GWAS$CHR)){
  nbp[i] <- max(GWAS[GWAS$CHR == i,]$BP)
  GWAS[GWAS$CHR == i,"BPcum"] <- GWAS[GWAS$CHR == i,"BP"] + s
  s <- s + nbp[i]
}


nCHR <- length(unique(intervals$scaffold))
intervals$BPcum <- NA
s <- 0
nbp <- c()
for (i in unique(intervals$scaffold)){
  nbp[i] <- max(intervals[intervals$scaffold == i,]$start)
  intervals[intervals$scaffold == i,"BPcum"] <- intervals[intervals$scaffold == i,"start"] + s
  s <- s + nbp[i]
}


axis.set <- GWAS %>% 
  group_by(CHR) %>% 
  summarize(center = (max(BPcum) + min(BPcum)) / 2)
ylim <- abs(floor(log10(min(GWAS$P)))) + 3
sig <- 0.05 / nrow(GWAS)


#calc sliding windows
for (i in 1:nrow(intervals)){
    win <- filter(dp, dp$scaffold==intervals$scaffold[i] & dp$pos>=intervals$start[i] & dp$pos<=intervals$end[i])
    intervals$DP_ratio[i] <- mean(win$DP_ratio)
    win <- NULL
}

# size of scaffold 11 needed to offset scaffold 12 points in figure
offset <- 30695582

# 
coeff <- 22 # trandorm depth by a factor of 25
pdf("GWAS_DP_ratio_genes.combined.pdf")
ggplot(GWAS, aes(x=BPcum, y=-log10(P))) +
  geom_point(aes(color=as.factor(CHR)), alpha = 0.75, size = 1.25) +
  scale_color_manual(values = rep(c("#a32126ff","#e09b45ff"), nCHR)) +
  scale_x_continuous(expand = c(0, 0), breaks = c(0, 10000000, 20000000, 30710079,40710079, 50710079), labels = c(0, 10000000, 20000000, 0, 10000000, 20000000)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,26),   sec.axis = sec_axis( trans=~./coeff, name="Depth Ratio", breaks = c(0, 0.25, 0.5, 0.75, 1))) +
  geom_point(data=AgraX_genes,aes(x=start+offset, y=25), shape=124, size=10, colour="#ad2e8dff", alpha=0.5) +
  geom_line(data=intervals, aes(x=BPcum, y=DP_ratio*coeff), size=1) +
  geom_hline(yintercept = -log10(sig), color = "grey40", linetype = "dashed") +
  labs(x = "Position", y = "-log10(P)\n") +
  theme_bw() +
  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8, vjust = 0.5, colour = "black"),
    axis.text.y = element_text(size = 8, colour = "black"))

dev.off()
