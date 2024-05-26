#'---
#' title: Find number of local samples. 
#' author:
#' wb:
#'  log:
#'   - snakemake: '`sm str(tmp_dir / "AS" / "{dataset}" / "00_1_flag_no_local.Rds")`'
#'  params:
#'   - ids: '`sm lambda w: sa.getIDsByGroup(w.dataset, assay="RNA")`'
#'  input:
#'   - sampleAnnoFile: '`sm config["sampleAnnotation"]`'
#'  output:
#'   - n_local: '`sm temp(cfg.getProcessedDataDir() + "/aberrant_splicing/datasets/savedObjects/raw-local-{dataset}/n_local.done")`'
#'  threads: 3
#'  type: script
#'---

saveRDS(snakemake, snakemake@log$snakemake)

#+ input
annoFile <- snakemake@input$sampleAnnoFile

#+ output
n_localFile <- snakemake@output$n_local

# Check the amount of local samples. 
anno <- fread(annoFile)
n_local <- if("EXTERNAL" %in% colnames(sum)) sum(anno[, "EXTERNAL"] == FALSE) else nrow(anno)

outConn <- file(n_localFile)
writeLines(c(str(n_local)), outConn)
close(outConn)