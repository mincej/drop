#'---
#' title: Full FRASER analysis over all datasets
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "FRASER_datasets.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "AS" / "FRASER_datasets.Rds")`'
#'   input:
#'     fraser_summary: '`sm expand(config["htmlOutputPath"] + "/AberrantSplicing/{dataset}--{annotation}_summary.html", annotation=cfg.genome.getGeneVersions(), dataset=cfg.AS.groups)`'
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "AS" / "FRASER_datasets.txt")`'
#' output: html_document
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

# Obtain the annotations and datasets
datasets <- snakemake@config$aberrantSplicing$groups
gene_annotation_names <- names(snakemake@config$geneAnnotation)

#+ echo=FALSE, results="asis"
devNull <- sapply(datasets, function(name){
    sapply(gene_annotation_names, function(version){
        cat(paste0(
            "<h1>Dataset: ", name, ", annotation ", version, "</h1>",
            "<p>",
            "</br>", "<a href='AberrantSplicing/", name, "--", version, "_summary.html'        >FRASER Summary</a>",
            "</br>", "</p>"
        ))
    })
})
