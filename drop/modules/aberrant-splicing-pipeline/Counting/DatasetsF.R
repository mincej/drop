#'---
#' title: FRASER counting analysis over all datasets
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "CountingOverview.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "AS" / "CountingOverview.Rds")`'
#'   input:
#'     counting_summary: '`sm expand(config["htmlOutputPath"] + "/AberrantSplicing/{dataset}_countSummary.html", dataset=cfg.AS.groups)`'
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "AS" / "CountingOverview.txt")`'
#' output: html_document
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

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
