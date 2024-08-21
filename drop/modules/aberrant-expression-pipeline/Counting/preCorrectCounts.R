#'---
#' title: Model-Out Confounder Effects
#' author: Joshua L. Major-Mincer
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AE" / "{annotation}" / "{dataset}" / "precorrection.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "AE" / "{annotation}" / "{dataset}" / "precorrection.Rds")`'
#'   input:
#'     ods: '`sm cfg.getProcessedResultsDir() + "/aberrant_expression/{annotation}/outrider/{dataset}/ods_unfitted.Rds" `'
#'   output:
#'     ods_norm: '`sm cfg.getProcessedResultsDir() + "/aberrant_expression/{annotation}/outrider/{dataset}/ods_corrected.Rds"`'
#'   type: script
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'     correctColumns: 'config["aberrantExpression"]["correctColumns"]'
#'   benchmark: '`sm str(bench_dir / "AE" / "{annotation}" / "{dataset}" / "precorrection.txt")`'
#'---

source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

suppressPackageStartupMessages({
    library(data.table)
    library(GenomicFeatures)
    library(SummarizedExperiment)
    library(DESeq2)
    library(OUTRIDER)
    library(glue)
})

# Grab the raw counts.
ods <- readRDS(snakemake@input$ods)
raw_matrix <- as.matrix(assay(ods))

# Annotation data.
anno <- colData(ods)

# Check correction columns. 
correct_cols <- c()
for(col in snakemake@params$correctColumns){
    if(!(col %in% colnames(anno))){
        stop(glue("{col} not found in annotation."))
    } else if(length(unique(anno[[col]])) == 1){
        warning(glue("{col} only has one unique value, {unique(anno[[col]])}, and is removed from linear model."))
    } else {
        correct_cols <- c(correct_cols, col)
    }
}

# Create new DESeq dataset, with the design matching any
# of the adjustment columns. 
raw_deseq <- DESeqDataSetFromMatrix(
    countData = raw_matrix,
    colData = anno,
    design = as.formula(glue("~ {paste(correct_cols, collapse = ' + ')}"))
)

# Normalize.
norm_deseq <- DeSeq(
    raw_deseq, 
    fitType = "parametric",
    minReplicatesForReplace = Inf
)

norm_matrix <- counts(norm_deseq, normalized = TRUE)

# Create OUTRIDER dataset with the new matrix. 
ods_norm <- OutriderDataSet(
    countData = norm_matrix,
    colData = colData(norm_deseq)
)

# Output. 
saveRDS(ods_norm, snakemake@output$ods_norm)
