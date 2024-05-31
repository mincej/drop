logSinker <- function(snakemake, log_file, stream_arg){
    if(stream_arg == "yes"){
        log <- file(log_file, "wt")
        sink(log, type = "output")
        sink(log, type = "message")
        on.exit(sink())
        str(snakemake)

    } else if (stream_arg == "tee"){

        # Output snakemake env without burdening terminal with redundancy. 
        log <- file(log_file, "wt")
        writeLines(paste0(capture.output(str(snakemake)), "\n"), log)

        sink(log, type = "output", split = TRUE)
        sink(log, type = "message")
        on.exit(sink())

    } else {
        saveRDS(snakemake, log_file)
    }
}