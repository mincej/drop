#'---
#' title: Results Overview
#' author: mumichae
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AE" / "OUTRIDER_Overview.log") if config["full_log"] else str(tmp_dir / "AE" / "OUTRIDER_Overview.Rds")`'
#'   input:
#'     summaries: '`sm expand(config["htmlOutputPath"] + "/AberrantExpression/Outrider/{annotation}/Summary_{dataset}.html", annotation=cfg.genome.getGeneVersions(), dataset=cfg.AE.groups)`'
#'   params:
#'     full_log: '`sm config["full_log"]`'
#'   benchmark: '`sm str(bench_dir / "AE" / "OUTRIDER_Overview.log") if config["full_log"] else str(bench_dir / "AE" / "OUTRIDER_Overview.txt")`'
#' output:
#'   html_document:
#'     code_folding: hide
#'     code_download: true
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

# Obtain the annotations and datasets
datasets <- snakemake@config$aberrantExpression$groups 
gene_annotation_names <- names(snakemake@config$geneAnnotation)

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
  sapply(gene_annotation_names, function(version){
    cat(paste0(
      "<h1>Dataset: ", name, ", annotation: ", version, "</h1>",
      "<p>",
      "</br>", "<a href='AberrantExpression/Outrider/", version, "/Summary_", name, ".html'   >OUTRIDER Summary</a>",
      "</br>", "</p>"
    ))
  })
})
