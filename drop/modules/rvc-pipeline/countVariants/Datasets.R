#'---
#' title: RVC datasets
#' author: nickhsmith
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "RVC" / "RVC_Datasets.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "RVC" / "RVC_Datasets.Rds")`'
#'   input:
#'     summaries: '`sm expand(config["htmlOutputPath"] + "/rnaVariantCalling/{annotation}/Summary_{dataset}.html", annotation=cfg.genome.getGeneVersions(), dataset=cfg.RVC.groups)`'
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "RVC" / "RVC_Datasets.txt")`'
#' output:
#'   html_document:
#'     code_folding: hide
#'     code_download: true
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

# Obtain the annotations and datasets
datasets <- snakemake@config$rnaVariantCalling$groups 
gene_annotation_names <- names(snakemake@config$geneAnnotation)

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
  sapply(gene_annotation_names, function(version){
    cat(paste0(
      "<h4>Dataset: ", name, ", annotation: ", version, "</h4>",
      "<p>",
      "</br>", "<a href='rnaVariantCalling/", version, "/Summary_", name, ".html'   >Summary</a>",
      "</br>", "</p>"
    ))
  })
})
