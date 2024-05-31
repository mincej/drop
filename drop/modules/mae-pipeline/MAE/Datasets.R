#'---
#' title: MAE analysis over all datasets
#' author: null
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "MAE" / "overview.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "MAE" / "overview.Rds")`'
#'   input:
#'     html: '`sm expand(config["htmlOutputPath"] + "/MonoallelicExpression/{dataset}--{annotation}_results.html", annotation=cfg.genome.getGeneVersions(), dataset=cfg.MAE.groups)`'
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "MAE" / "overview.txt")`'
#' output: html_document
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

# Obtain the annotations and datasets
datasets <- snakemake@config$mae$groups 
gene_annotation_names <- names(snakemake@config$geneAnnotation)

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
  sapply(gene_annotation_names, function(version){
    cat(paste0(
      "<h1>Dataset: ", name, ", annotation ", version, "</h1>",
      "<p>",
      "</br>", "<a href='MonoallelicExpression/", name, "--", version, "_results.html'   >MAE results</a>",
      "</br>", "</p>"
    ))
  })
})

