#'---
#' title: Counts Overview
#' author: mumichae, salazar
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AE" / "Count_Overview.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "AE" / "Count_Overview.Rds")`'
#'   input:
#'     summaries: '`sm expand(config["htmlOutputPath"] + "/AberrantExpression/Counting/{annotation}/Summary_{dataset}.html", annotation=cfg.genome.getGeneVersions(), dataset=cfg.AE.groups)`'
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "AE" / "Count_Overview.txt")`'
#' output:
#'   html_document:
#'     code_folding: hide
#'     code_download: true
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

# Obtain the annotations and datasets
gene_annotation_names <- names(snakemake@config$geneAnnotation)
datasets <- snakemake@config$aberrantExpression$groups

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
  sapply(gene_annotation_names, function(version){
    cat(paste0(
      "<h1>Dataset: ", name, ", annotation: ", version, "</h1>",
      "<p>",
      "</br>", "<a href='AberrantExpression/Counting/", version, "/Summary_", name, ".html'   >Count Summary</a>",
      "</br>", "</p>"
    ))
  })
})
