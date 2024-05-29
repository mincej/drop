logSinker <- function(snakemake, log_file, stream_arg){
    if(stream_arg == "yes"){
        log <- file(log_file, open = "wt")

        sink(log, type = "output")
        sink(log, type = "message")
        print(snakemake)
    } else if (stream_arg == "tee"){
        log <- file(log_file, open = "wt")

        sink(log, type = "output", split = TRUE)
        sink(log, type = "message")
        print(snakemake)
    } else {
        saveRDS(snakemake, log_file)
    }
}