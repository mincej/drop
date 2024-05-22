#'---
#' title: FRASER counting analysis over all datasets
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "CountingOverview.log") if config["full_log"] else str(tmp_dir / "AS" / "CountingOverview.Rds")`'
#'   input:
#'     counting_summary: '`sm expand(config["htmlOutputPath"] + "/AberrantSplicing/{dataset}_countSummary.html", dataset=cfg.AS.groups)`'
#'   params:
#'     full_log: '`sm config["full_log"]`'
#'   benchmark: '`sm str(bench_dir / "AS" / "CountingOverview.log") if config["full_log"] else str(bench_dir / "AS" / "CountingOverview.txt")`'
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

datasets <- snakemake@config$aberrantSplicing$groups

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
  cat(paste0(
    "<h1>Dataset: ", name, "</h1>",
    "<p>",
    "</br>", "<a href='AberrantSplicing/", name, "_countSummary.html'   >Count Summary</a>",
    "</br>", "</p>"
  ))
})
