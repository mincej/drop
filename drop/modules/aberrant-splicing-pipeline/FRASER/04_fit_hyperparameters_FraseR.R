#'---
#' title: Hyper parameter optimization
#' author: Christian Mertes
#' wb:
#'   log:
#'     snakemake: '`sm str(tmp_dir / "AS" / "{dataset}" / "04_hyper.log") if cfg.get("stream_to_log") != "no" else str(tmp_dir / "AS" / "{dataset}" / "04_hyper.Rds")`'
#'   params:
#'     setup: '`sm cfg.AS.getWorkdir() + "/config.R"`'
#'     workingDir: '`sm cfg.getProcessedDataDir() + "/aberrant_splicing/datasets/"`'
#'     logSinker: '`sm str(projectDir / ".drop" / "helpers" / "log_sinker.R")`'
#'   threads: 12
#'   input:
#'     filter: '`sm expand(cfg.getProcessedDataDir() + "/aberrant_splicing/datasets/savedObjects/{dataset}/filter_{version}.done", version=cfg.AS.get("FRASER_version"), allow_missing=True)`'
#'   output:
#'     hyper: '`sm expand(cfg.getProcessedDataDir() + "/aberrant_splicing/datasets/savedObjects/{dataset}/hyper_{version}.done", version=cfg.AS.get("FRASER_version"), allow_missing=True)`'
#'   type: script
#'   benchmark: '`sm str(bench_dir / "AS" / "{dataset}" / "04_hyper.txt")`'
#'---


source(snakemake@params$logSinker)
logSinker(snakemake, snakemake@log$snakemake, snakemake@config$stream_to_log)
source(snakemake@params$setup, echo=FALSE)

if ("random_seed" %in% names(snakemake@config)){
  rseed <- snakemake@config$random_seed
  if(isTRUE(rseed)){
    set.seed(42)
  } else if (is.numeric(rseed)){
    set.seed(as.integer(rseed))
  }
}

#+ input
dataset    <- snakemake@wildcards$dataset
workingDir <- snakemake@params$workingDir

register(MulticoreParam(snakemake@threads))
# Limit number of threads for DelayedArray operations
setAutoBPPARAM(MulticoreParam(snakemake@threads))

# Load PSI data
fds <- loadFraserDataSet(dir=workingDir, name=dataset)
fitMetrics(fds) <- psiTypes

# Run hyper parameter optimization
implementation <- snakemake@config$aberrantSplicing$implementation
mp <- snakemake@config$aberrantSplicing$maxTestedDimensionProportion

# Get range for latent space dimension
a <- 2 
b <- min(ncol(fds), nrow(fds)) / mp   # N/mp

maxSteps <- 12
if(mp < 6){
  maxSteps <- 15
}

Nsteps <- min(maxSteps, b)
pars_q <- round(exp(seq(log(a),log(b),length.out = Nsteps))) %>% unique

for(type in psiTypes){
    message(date(), ": ", type)
    fds <- optimHyperParams(fds, type=type, 
                            implementation=implementation,
                            q_param=pars_q,
                            plot = FALSE)
    fds <- saveFraserDataSet(fds)
}
fds <- saveFraserDataSet(fds)

# remove previous hyper.done files and create new one
outdir <- dirname(snakemake@output$hyper)
prevFilterFiles <- grep("hyper(.*)done", list.files(outdir), value=TRUE)
unlink(file.path(outdir, prevFilterFiles))
file.create(snakemake@output$hyper)
