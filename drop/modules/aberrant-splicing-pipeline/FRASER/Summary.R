#'---
#' title: "FRASER Summary: `r paste(snakemake@wildcards$dataset, snakemake@wildcards$annotation, sep = '--')`"
#' author: mumichae, vyepez, ischeller
#' wb:
#'  log:
#'    - snakemake: '`sm str(tmp_dir / "AS" / "{dataset}--{annotation}" / "FRASER_summary.Rds")`'
#'  params:
#'   - setup: '`sm cfg.AS.getWorkdir() + "/config.R"`'
#'  input:
#'   - fdsin: '`sm cfg.getProcessedResultsDir() + 
#'                 "/aberrant_splicing/datasets/savedObjects/{dataset}--{annotation}/fds-object.RDS"`'
#'   - results: '`sm cfg.getProcessedResultsDir() + 
#'                   "/aberrant_splicing/results/{annotation}/fraser/{dataset}/results.tsv"`'
#'  output:
#'   - wBhtml: '`sm config["htmlOutputPath"] +
#'               "/AberrantSplicing/{dataset}--{annotation}_summary.html"`'
#'   - res_html: '`sm config["htmlOutputPath"] +
#'               "/AberrantSplicing/FRASER_results_{dataset}--{annotation}.tsv"`'
#'  type: noindex
#'---

saveRDS(snakemake, snakemake@log$snakemake)
source(snakemake@params$setup, echo=FALSE)

suppressPackageStartupMessages({
  library(cowplot)
  library(RColorBrewer)
})

#+ input
dataset    <- snakemake@wildcards$dataset
annotation <- snakemake@wildcards$annotation
padj_cutoff <- snakemake@config$aberrantSplicing$padjCutoff
deltaPsi_cutoff <- snakemake@config$aberrantSplicing$deltaPsiCutoff


fds <- loadFraserDataSet(file=snakemake@input$fdsin)
hasExternal <- length(levels(colData(fds)$isExternal) > 1)

#' Number of samples: `r nrow(colData(fds))`
#' 
#' Number of introns: `r length(rowRanges(fds, type = "j"))`
#' 
#' Number of splice sites: `r length(rowRanges(fds, type = "ss"))`

# used for most plots
dataset_title <- paste0("Dataset: ", dataset, "--", annotation)


#' ## Hyperparameter optimization
for(type in psiTypes){
  g <- plotEncDimSearch(fds, type=type) 
  if (!is.null(g)) {
    g <- g + theme_cowplot(font_size = 16) + 
      ggtitle(paste0("Q estimation, ", type)) + theme(legend.position = "none")
    print(g)
  }
}

#' ## Aberrantly spliced genes per sample
plotAberrantPerSample(fds, type=psiTypes, 
                      padjCutoff = padj_cutoff, deltaPsiCutoff = deltaPsi_cutoff,
                      aggregate=TRUE, main=dataset_title) + 
  theme_cowplot(font_size = 16) +
  theme(legend.position = "top")

#' ## Batch Correlation: samples x samples
topN <- 30000
topJ <- 10000

# We can have many external datasets. 
count_dirs <- unique(fds$SPLICE_COUNTS_DIR)
anno_color_scheme <- brewer.pal(n = length(count_dirs), name = 'Dark2')
anno_colors <- list()
for(i in seq_along(count_dirs)){
  anno_colors[count_dirs[[i]]] = anno_color_scheme[i]
}

for(type in psiTypes){
  for(normalized in c(F,T)){
    hm <- plotCountCorHeatmap(
      object=fds,
      type = type,
      logit = TRUE,
      topN = topN,
      topJ = topJ,
      plotType = "sampleCorrelation",
      normalized = normalized,
      annotation_col = "SPLICE_COUNTS_DIR",
      annotation_row = NA,
      sampleCluster = NA,
      minDeltaPsi = minDeltaPsi,
      plotMeanPsi = FALSE,
      plotCov = FALSE,
      annotation_legend = TRUE,
      annotation_colors = anno_colors
    )
    hm
  }
}

#' ## Results
res <- fread(snakemake@input$results)

#' Total gene-level splicing outliers: `r nrow(res)`
#' 

file <- snakemake@output$res_html
write_tsv(res, file = file)
#+ echo=FALSE, results='asis'
cat(paste0("<a href='./", basename(file), "'>Download FRASER results table</a>"))

# round numbers
if(nrow(res) > 0){
  res[, pValue := signif(pValue, 3)]
  res[, deltaPsi := signif(deltaPsi, 2)]
  res[, psiValue := signif(psiValue, 2)]
  res[, pValueGene := signif(pValueGene, 2)]
  padjGene_cols <- grep("padjustGene", colnames(res), value=TRUE)
  for(padj_col in padjGene_cols){
      res[, c(padj_col) := signif(get(padj_col), 2)]
  }
}

DT::datatable(
  head(res, 1000),
  caption = 'FRASER results (up to 1,000 rows shown)',
  options=list(scrollX=TRUE),
  escape=FALSE,
  filter = 'top'
)
