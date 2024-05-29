logSinker <- function(snakemake, log_file, stream_arg){
    if(stream_arg == "yes"){

        sink(log_file, type = "output")
        sink(log_file, type = "message")
        on.exit(sink())
        print(snakemake)

    } else if (stream_arg == "tee"){

        # Output snakemake env without burdening terminal with redundancy. 
        log <- file(log_file, "wt")
        writeLines(print(snakemake), log)
        close(log)

        sink(log_file, type = "output", split = TRUE)
        sink(log_file, type = "message")
        on.exit(sink())
        print(snakemake)

    } else {
        saveRDS(snakemake, log_file)
    }
    
}