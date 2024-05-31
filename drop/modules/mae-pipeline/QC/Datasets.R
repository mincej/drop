#'---
#' title: VCF-BAM Matching Analysis over All Datasets
#' author: null
#' author: null
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "MAE" / "QC_overview.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "MAE" / "QC_overview.Rds")`'
#'   input:
#'     html: '`sm expand( config["htmlOutputPath"] + "/MonoallelicExpression/QC/{dataset}.html", dataset=cfg.MAE.qcGroups )`'
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "MAE" / "QC_overview.txt")`'
#' output: html_document
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

# Obtain the datasets
datasets <- snakemake@config$mae$qcGroups 

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
    cat(paste0(
      "<h1>Dataset: ", name, "</h1>",
      "<p>",
      "</br>", "<a href='MonoallelicExpression/QC/", name, ".html'   >QC overview</a>",
      "</br>", "</p>"
    ))
})
