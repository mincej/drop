#'---
#' title: Create GeneID-GeneName mapping
#' author: mumichae
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "MAE" / "{annotation}.log") if config["full_log"] else str(tmp_dir / "MAE" / "{annotation}.Rds")`'
#'   input:
#'     gtf: '`sm lambda w: cfg.genome.getGeneAnnotationFile(w.annotation) `'
#'   output:
#'     gene_name_mapping: '`sm cfg.getProcessedDataDir() + "/mae/gene_name_mapping_{annotation}.tsv"`'
#'   type: script
#'   params:
#'     full_log: '`sm config["full_log"]`'
#'   benchmark: '`sm str(bench_dir / "MAE" / "{annotation}.log") if config["full_log"] else str(bench_dir / "MAE" / "{annotation}.txt")`'
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

suppressPackageStartupMessages({
  library(rtracklayer)
  library(data.table)
  library(magrittr)
  library(tidyr)
})

gtf_dt <- import(snakemake@input$gtf) %>% as.data.table
if (!"gene_name" %in% colnames(gtf_dt)) {
  gtf_dt[gene_name := gene_id]
}
if('gene_biotype' %in% colnames(gtf_dt))
   setnames(gtf_dt, 'gene_biotype', 'gene_type')
gtf_dt <- gtf_dt[type == "gene", .(seqnames, start, end, strand, gene_id, gene_name, gene_type)]

# make gene_names unique
gtf_dt[, N := 1:.N, by = gene_name] # warning message
gtf_dt[, gene_name_orig := gene_name]
gtf_dt[N > 1, gene_name := paste(gene_name, N, sep = '_')]
gtf_dt[, N := NULL]

fwrite(gtf_dt, snakemake@output$gene_name_mapping, na = NA)
