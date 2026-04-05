library(karyoploteR) # v 1.16.0
library(ggplot2)
library(dplyr)
library(ggpubr)
library(grDevices)


# set working directory
setwd("~/Library/CloudStorage/GoogleDrive-pbentz@hudsonalpha.org/Other computers/My Mac/Documents/Cannabis/Analysis_data/mapping_cov")

########################

# read in lengths file for custom genome
## MAKE SURE TO ONLY INCLUDE THE CHROMOSOME SCALE SCAFFOLDS (IE, LONGER SCAFFOLDS)
Chrom_Lengths <- read.table("karyoplotR_reference.lengths.txt", header=TRUE)

## create custom genome for plotting
custom.genome <- toGRanges(data.frame(chr=Chrom_Lengths$Chromosome, start=Chrom_Lengths$ChromStart, end=Chrom_Lengths$ChromEnd))

########################

# read in mapping depth results for one sample
a <- read.table("US031_2x-depth.50kb_windows.21mer_DEPTH.txt")
# add column names for plotting easier
colnames(a) <- c("Chromosome","Start","Stop","cov")
# check summary of data
summary(a)

# use the ifelse function to replace values in cov column (ie, maximum cutoff of 8x coverage depth)
a$cov <- ifelse(a$cov > 8, 8, a$cov)

# convert kmer_cov to dataframe for plotting
coverage.GR <- toGRanges(data.frame(chr=a$Chromosome, start=a$Start, end=a$Stop))

# name chromosomes for plot 
names=c("Chr01","Chr02","Chr03","Chr04","Chr05","Chr06","Chr07","Chr08","Chr09","ChrY")


all.genes <- genes("/Users/pb/Library/CloudStorage/GoogleDrive-pbentz@hudsonalpha.org/Other computers/My Mac/Documents/Cannabis/Analysis_data/SCarey_assemblies_annotations/genes/OIIa.primary_high_confidence.ChrRenamed.gff3")

#######################################################################################################
############################ make plot showing kmer coverage across genome ############################
#######################################################################################################


# output pdf of plot
pdf(file="karyoplotr.pdf", width=16)
pp <- getDefaultPlotParams(plot.type = 4)
pp$leftmargin <- 0.1
kp <- plotKaryotype(genome=custom.genome, pin=8, plot.type = 4,labels.plotter = NULL, plot.params=pp)
kpAddChromosomeNames(kp, chr.names= names, srt=360, yoffset=-2, cex=1.5)
kpAddBaseNumbers(kp, tick.dist = 50000000, tick.len = 5, tick.col="black", cex=0.8,
                 minor.tick.dist = 10000000, minor.tick.len = 2.5, minor.tick.col = "black", add.units = F)


# create part of graph for male-biased kmers from only Ahorr
kp <-kpArea(kp, data=coverage.GR, data.panel = 1, col=transparent(("red"), amount=0.20), y=a$cov,
            ymin=0, ymax=8, r0=0.01, r1=0.25,lwd=0.5)

# track 2
kp <-kpArea(kp, data=coverage.GR, data.panel = 1, col=transparent(("blue"), amount=0.20), y=b$cov,
            ymin=0, ymax=8, r0=0.3, r1=0.54,lwd=0.5)

# axis labels
kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=1, numticks=3, 
       labels=c("0","4","8"), 
       r0=0.01, r1=0.25, side=1)


# label
kp <- kpAddLabels(kp,data.panel = 1,r0=0.25, r1=0.25,"B", label.margin=0.04, cex=1.5)

# add main plot title
kpAddMainTitle(kp, main="Long-read low-pass mapping depth")
# close pdf
dev.off()



