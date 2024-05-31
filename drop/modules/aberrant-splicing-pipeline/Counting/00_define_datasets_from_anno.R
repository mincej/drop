#'---
#' title: Create datasets from annotation file
#' author: Christian Mertes, mumichae
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "{dataset}" / "00_defineDataset.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "AS" / "{dataset}" / "00_defineDataset.Rds")`'
#'   params:
#'     setup: '`sm cfg.AS.getWorkdir() + "/config.R"`'
#'     ids: '`sm lambda w: sa.getIDsByGroup(w.dataset, assay="RNA")`'
#'     fileMappingFile: '`sm cfg.getRoot() + "/file_mapping.csv"`'
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   input:
#'     sampleAnnoFile: '`sm config["sampleAnnotation"]`'
#'   output:
#'     colData: '`sm cfg.getProcessedDataDir() + "/aberrant_splicing/annotations/{dataset}.tsv"`'
#'     wBhtml: '`sm config["htmlOutputPath"] + "/AberrantSplicing/annotations/{dataset}.html"`'
#'   type: noindex
#'   benchmark: '`sm str(bench_dir / "AS" / "{dataset}" / "00_defineDataset.txt")`'
#' output:
#'   html_document:
#'     code_folding: hide
#'     code_download: true
#'   html_document:
#'     code_folding: hide
#'     code_download: true
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)
source(snakemake@params$setup, echo=FALSE)

#+ input
outFile       <- snakemake@output$colData
annoFile      <- snakemake@input$sampleAnnoFile
fileMapFile   <- snakemake@params$fileMapping

#+ dataset name

name <- snakemake@wildcards$dataset
anno    <- fread(annoFile)
mapping <- fread(fileMapFile)

subset_ids <- snakemake@params$ids
annoSub <- anno[RNA_ID %in% subset_ids]
setnames(annoSub, "RNA_ID", "sampleID")
colData <- merge(annoSub,
    mapping[FILE_TYPE == "RNA_BAM_FILE", .(sampleID=ID, bamFile=FILE_PATH)])
setcolorder(colData, unique(c("sampleID", "STRAND", "PAIRED_END", "bamFile"), colnames(annoSub)))

#'
#' ## Dataset: `r name`
#'
#+ echo=FALSE
finalTable <- colData

#'
#' ## Final sample table `r name`
#'
#+ savetable
DT::datatable(finalTable, options=list(scrollX=TRUE))

dim(finalTable)
write_tsv(finalTable, file=outFile)
