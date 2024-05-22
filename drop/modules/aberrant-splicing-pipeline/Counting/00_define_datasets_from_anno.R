#'---
#' title: Create datasets from annotation file
#' author: Christian Mertes, mumichae
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "{dataset}" / "00_defineDataset.log") if config["full_log"] else str(tmp_dir / "AS" / "{dataset}" / "00_defineDataset.Rds")`'
#'   params:
#'     setup: '`sm cfg.AS.getWorkdir() + "/config.R"`'
#'     ids: '`sm lambda w: sa.getIDsByGroup(w.dataset, assay="RNA")`'
#'     fileMappingFile: '`sm cfg.getRoot() + "/file_mapping.csv"`'
#'     full_log: '`sm config["full_log"]`'
#'   input:
#'     sampleAnnoFile: '`sm config["sampleAnnotation"]`'
#'   output:
#'     colData: '`sm cfg.getProcessedDataDir() + "/aberrant_splicing/annotations/{dataset}.tsv"`'
#'     wBhtml: '`sm config["htmlOutputPath"] + "/AberrantSplicing/annotations/{dataset}.html"`'
#'   type: noindex
#'   benchmark: '`sm str(bench_dir / "AS" / "{dataset}" / "00_defineDataset.log") if config["full_log"] else str(bench_dir / "AS" / "{dataset}" / "00_defineDataset.txt")`'
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
