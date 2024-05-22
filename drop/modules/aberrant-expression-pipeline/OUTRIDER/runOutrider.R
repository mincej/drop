#'---
#' title: Filter Counts for OUTRIDER
#' author: Michaela Mueller
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AE" / "{annotation}" / "{dataset}" / "runOUTRIDER.log") if config["full_log"] else str(tmp_dir / "AE" / "{annotation}" / "{dataset}" / "runOUTRIDER.Rds")`'
#'   input:
#'     ods: '`sm cfg.getProcessedResultsDir() + "/aberrant_expression/{annotation}/outrider/{dataset}/ods_unfitted.Rds"`'
#'   output:
#'     ods_fitted: '`sm cfg.getProcessedResultsDir() + "/aberrant_expression/{annotation}/outrider/{dataset}/ods_fitted.Rds"`'
#'   type: script
#'   threads: 30
#'   params:
#'     full_log: '`sm config["full_log"]`'
#'   benchmark: '`sm str(bench_dir / "AE" / "{annotation}" / "{dataset}" / "runOUTRIDER.log") if config["full_log"] else str(bench_dir / "AE" / "{annotation}" / "{dataset}" / "runOUTRIDER.txt")`'
#'---

#+ echo=F

log_file <- snakemake@log$snakemake
if(snakemake@params$full_log){
    log <- file(log_file, open = "wt")

    sink(log, type = "output")
    sink(log, type = "message")
    print(snakemake)
} else {
    saveRDS(snakemake, log_file)
}

suppressPackageStartupMessages({
    library(OUTRIDER)
    library(SummarizedExperiment)
    library(ggplot2)
    library(data.table)
    library(dplyr)
    library(magrittr)
    library(tools)
})

ods <- readRDS(snakemake@input$ods)
implementation <- snakemake@config$aberrantExpression$implementation
mp <- snakemake@config$aberrantExpression$maxTestedDimensionProportion
register(MulticoreParam(snakemake@threads))

## subset filtered
ods <- ods[mcols(ods)$passedFilter,] 

# add gene ranges to rowData
gr <- unlist(endoapply(rowRanges(ods), range))
if(length(gr) > 0){
    rd <- rowData(ods)
    rowRanges(ods) <- gr
    rowData(ods) <- rd
}

ods <- estimateSizeFactors(ods)

## find optimal encoding dimension
a <- 5 
b <- min(ncol(ods), nrow(ods)) / mp   # N/3

maxSteps <- 15
if(mp < 4){
    maxSteps <- 20
}

Nsteps <- min(maxSteps, b)   # Do at most 20 steps or N/3
# Do unique in case 2 were repeated
pars_q <- round(exp(seq(log(a),log(b),length.out = Nsteps))) %>% unique
ods <- findEncodingDim(ods, params = pars_q, implementation = implementation)
opt_q <- getBestQ(ods)

## fit OUTRIDER
# ods <- OUTRIDER(ods, implementation = implementation)
message(date(), ": SizeFactor estimation ...")
ods <- estimateSizeFactors(ods)
message(date(), ": Controlling for confounders ...")
implementation <- tolower(implementation)
ods <- controlForConfounders(ods, q=opt_q, implementation=implementation)
if(grepl("^(peer|pca)$", implementation)){
    message(date(), ": Fitting the data ...")
    ods <- fit(ods)
}
message("outrider fitting finished")

saveRDS(ods, snakemake@output$ods_fitted)
