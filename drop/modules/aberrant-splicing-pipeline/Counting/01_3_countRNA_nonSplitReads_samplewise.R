#'---
#' title: Nonsplit Counts
#' author: Luise Schuller
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "{dataset}" / "nonsplitReads" / "{sample_id}.log") if config["full_log"] else str(tmp_dir / "AS" / "{dataset}" / "nonsplitReads" / "{sample_id}.Rds")`'
#'   params:
#'     setup: '`sm cfg.AS.getWorkdir() + "/config.R"`'
#'     workingDir: '`sm cfg.getProcessedDataDir() + "/aberrant_splicing/datasets"`'
#'     full_log: '`sm config["full_log"]`'
#'   input:
#'     spliceSites: '`sm cfg.getProcessedDataDir() + "/aberrant_splicing/datasets/cache/raw-local-{dataset}/spliceSites_splitCounts.rds"`'
#'   output:
#'     done_sample_nonSplitCounts: '`sm cfg.getProcessedDataDir() + "/aberrant_splicing/datasets/cache/raw-local-{dataset}/sample_tmp/nonSplitCounts/sample_{sample_id}.done"`'
#'   threads: 3
#'   type: script
#'   benchmark: '`sm str(bench_dir / "AS" / "{dataset}" / "nonsplitReads" / "{sample_id}.log") if config["full_log"] else str(bench_dir / "AS" / "{dataset}" / "nonsplitReads" / "{sample_id}.txt")`'
#'---


log_file <- snakemake@log$snakemake
if(snakemake@params$full_log){
    log <- file(log_file, open = "wt")

    sink(log, type = "output")
    sink(log, type = "message")
    print(snakemake)
} else {
    saveRDS(snakemake, log_file)
}
source(snakemake@params$setup, echo=FALSE)

dataset    <- snakemake@wildcards$dataset
colDataFile <- snakemake@input$colData
workingDir <- snakemake@params$workingDir
params <- snakemake@config$aberrantSplicing

# Read FRASER object
fds <- loadFraserDataSet(dir=workingDir, name=paste0("raw-local-", dataset))

# Get sample id from wildcard
sample_id <- snakemake@wildcards[["sample_id"]]


# Read splice site coordinates from RDS
spliceSiteCoords <- readRDS(snakemake@input$spliceSites)

# Count nonSplitReads for given sample id
sample_result <- countNonSplicedReads(sample_id,
                                      splitCountRanges = NULL,
                                      fds = fds,
                                      NcpuPerSample = snakemake@threads,
                                      minAnchor=5,
                                      recount=params$recount,
                                      spliceSiteCoords=spliceSiteCoords,
                                      longRead=params$longRead)

message(date(), ": ", dataset, ", ", sample_id,
        " no. splice junctions (non split counts) = ", length(sample_result))

file.create(snakemake@output$done_sample_nonSplitCounts)
