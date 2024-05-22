#'---
#' title: VCF-BAM Matching Analysis over All Datasets
#' author: null
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "MAE" / "QC_overview.log") if config["full_log"] else str(tmp_dir / "MAE" / "QC_overview.Rds")`'
#'   input:
#'     html: '`sm expand( config["htmlOutputPath"] + "/MonoallelicExpression/QC/{dataset}.html", dataset=cfg.MAE.qcGroups )`'
#'   params:
#'     full_log: '`sm config["full_log"]`'
#'   benchmark: '`sm str(bench_dir / "MAE" / "QC_overview.log") if config["full_log"] else str(bench_dir / "MAE" / "QC_overview.txt")`'
#' output: html_document
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
