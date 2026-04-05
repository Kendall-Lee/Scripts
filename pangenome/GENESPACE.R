###INSTALLATION #code by Laramie Akozbek

#detach("package:GENESPACE", unload = TRUE)
#devtools::install_github("jtlovell/GENESPACE", upgrade = TRUE, force = TRUE)

###prior to opening RStudio, in the command line:

# conda activate orthofinder
# open -na rstudio

#for some reason, with this combo of GENESPACE (v1.3.1), Orthofinder (v2.54 using python2.7), DIAMOND (v2.015) and RStudio (4.3.2), I have to install scipy within RStudio -- super frustrating
#note to self: re-build GENESPACE using updated version of Orthofinder after PAG

library(reticulate)
py_install("scipy")

####M. cerifera Hap1 to Hap2, Chr08

library(GENESPACE)
packageVersion("GENESPACE")

genomeRepo <- "~/Desktop/January/PAG24_MC3/rawGenomes"
wd <- "~/Desktop/January/PAG24_MC3"
path2mcscanx <- "~/Desktop/MCScanX/"

?parse_annotations()
R.Version()

parsedPaths <- parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = c("Mcerifera_hap1", "Mcerifera_hap2"),
  genomeIDs = c("Mcerifera_hap1", "Mcerifera_hap2"),
  headerEntryIndex = 1,
  gffString = "gff3",
  faString = "fa",
  gffIdColumn = "transcript_id",
  genespaceWd = wd)

gpar <- init_genespace(
  wd = wd,
  path2mcscanx = path2mcscanx)

out <- run_genespace(gpar)

roi <- data.frame(genome = c("Mcerifera_hap1", "Mcerifera_hap2"), chr = c("chr08", "chr08"), color = c("orange"))

ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))

ripDat <- plot_riparian(
  gsParam = out,
  highlightBed = roi,
  backgroundColor = NULL,
  addThemes = ggthemes,
  chrFill = c("grey"),
  useOrder = FALSE,
  genomeIDs = c("Mcerifera_hap1", "Mcerifera_hap2"),
  refGenome = "Mcerifera_hap1")

?plot_riparian()

##########################################################

roi <- data.frame(genome = c("Mcerifera_hap1", "Mcerifera_hap2"), chr = c("chr08", "chr08"), color = c("orange"))

ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))
