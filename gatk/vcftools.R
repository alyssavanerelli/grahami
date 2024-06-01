# Checking what parameters to filter by in vcftools
# Code used here was adopted from: https://speciationgenomics.github.io/filtering_vcfs/


# load tidyverse package
library(tidyverse)
library('ggplot2')

wd <- "~/Desktop/grahami/gatk:snpeff/vcftools_tables/"
setwd(wd)
list.files(wd)



# Variants ----------------------------------------------------------------

## Read in data
var_qual <- read_delim("DTG-SG-149_snps_vcftools.lqual", delim = "\t",
                       col_names = c("chr", "pos", "qual"), skip = 1)

var_depth <- read_delim("DTG-SG-149_snps_vcftools.ldepth.mean", delim = "\t",
                        col_names = c("chr", "pos", "mean_depth", "var_depth"), skip = 1)

var_miss <- read_delim("DTG-SG-149_snps_vcftools.lmiss", delim = "\t",
                       col_names = c("chr", "pos", "nchr", "nfiltered", "nmiss", "fmiss"), skip = 1)

var_freq <- read_delim("DTG-SG-149_snps_vcftools.frq", delim = "\t",
                       col_names = c("chr", "pos", "nalleles", "nchr", "a1", "a2"), skip = 1)

var_freq$maf <- var_freq %>% select(a1, a2) %>% apply(1, function(z) min(z))

ind_depth <- read_delim("DTG-SG-149_snps_vcftools.idepth", delim = "\t",
                        col_names = c("ind", "nsites", "depth"), skip = 1)

ind_miss  <- read_delim("DTG-SG-149_snps_vcftools.imiss", delim = "\t",
                        col_names = c("ind", "ndata", "nfiltered", "nmiss", "fmiss"), skip = 1)

ind_het <- read_delim("DTG-SG-149_snps_vcftools.het", delim = "\t",
                      col_names = c("ind","ho", "he", "nsites", "f"), skip = 1)


## Plotting

#### Variant Quality 
a <- ggplot(var_qual, aes(qual)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#a + theme_light() + xlim(0, 3000) + geom_vline(xintercept=30, size=0.7) + ggtitle("Variant Quality - SNPs")


#### Variant mean depth 
b <- ggplot(var_depth, aes(mean_depth)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#b + theme_light()  + ggtitle("Variant Mean Depth - SNPs") + xlim(0,400)

# The mean depth might be misleading from above plot as few variants may be with extremely high coverage
# look closely at mean depth
summary(var_depth$mean_depth)

#### Variant missingness
c <- ggplot(var_miss, aes(fmiss)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#c + theme_light() + xlim(-0.2, 1) + ggtitle("Variant Missingness - SNPs")

# Check summary data 
summary(var_miss$fmiss)

#### Minor allele frequency 
# To find minor allele frequency at each site, we need to use a bit of dplyr based code 
# find minor allele frequency
d <- ggplot(var_freq, aes(maf)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#d + theme_light() + xlim(-0.05, 0.6) + ggtitle("Minor Allele Freq - SNPs") 

# Check distribution in more detail 
summary(var_freq$maf)

#### Mean depth per individual 
e <- ggplot(ind_depth, aes(depth)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#e + theme_light() + ggtitle("Mean Depth per Ind - SNPs")

#### Proportion of missing data per individual 
f <- ggplot(ind_miss, aes(fmiss)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#f + theme_light() + ggtitle("Proportion of Missing Data per Ind - SNPs")

#### Heterozygosity and inbreeding coefficient per individual 
g <- ggplot(ind_het, aes(f)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)
#g + theme_light() + ggtitle("Heterozygosity and inbreeding coefficient per Ind - SNPs")

# Once you have assessed these plots - configure your vcftools to filter for variants of interest

## Saving plots as PDF
pdf("DTG-SG-149_vcftools.pdf")
a + theme_light() + xlim(0, 3000) + geom_vline(xintercept=30, size=0.7) + ggtitle("Variant Quality - SNPs")
b + theme_light()  + ggtitle("Variant Mean Depth - SNPs") + xlim(0,400)
c + theme_light() + xlim(-0.2, 1) + ggtitle("Variant Missingness - SNPs")
d + theme_light() + xlim(-0.05, 0.6) + ggtitle("Minor Allele Freq - SNPs") 
e + theme_light() + ggtitle("Mean Depth per Ind - SNPs")
f + theme_light() + ggtitle("Proportion of Missing Data per Ind - SNPs")
g + theme_light() + ggtitle("Heterozygosity and inbreeding coefficient per Ind - SNPs")
dev.off()
