#'---
#' title: Create GeneID-GeneName mapping
#' author: mumichae
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "MAE" / "{annotation}.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "MAE" / "{annotation}.Rds")`'
#'   input:
#'     gtf: '`sm lambda w: cfg.genome.getGeneAnnotationFile(w.annotation) `'
#'   output:
#'     gene_name_mapping: '`sm cfg.getProcessedDataDir() + "/mae/gene_name_mapping_{annotation}.tsv"`'
#'   type: script
#'   params:
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   benchmark: '`sm str(bench_dir / "MAE" / "{annotation}.txt")`'
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)

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
