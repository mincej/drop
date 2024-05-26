library(FRASER)

# Subset count matrix from gRange. 
getCountMatrix <- function(grange){
    count_matrix <- as.matrix(mcols(grange)[,,drop=FALSE])
    mode(count_matrix) <- "integer"
    return(count_matrix)
}

# FRASER does not provide a function to ONLY read in external counts. This function does
# just that in the absence of local samples. 
# Modified from the mergeExternal function from FRASER. 
externalFRASER <- function(count_dir, annotation_file, fds_dir, fds_name, samples){

    ### EXTERNAL DATA ###
    # Modified from FRASER mergeExternal. 
    exAnno <- fread(annotation_file, key="RNA_ID")
    setnames(exAnno, "RNA_ID", "sampleID")
    exAnno <- DataFrame(exAnno)
    rownames(exAnno) <- exAnno$sampleID
    exAnno <- exAnno[samples, ]


    ctsNames <- c("k_j", "k_theta", "n_psi3", "n_psi5", "n_theta")
    names(ctsNames) <- ctsNames
    ctsFiles <- paste0(count_dir, "/", ctsNames, "_counts.tsv.gz")
    names(ctsFiles) <- gsub("(_counts)?.tsv.gz", "", basename(ctsFiles))

    ### RAW GRANGES
    extCts <- lapply(ctsFiles, function(f){
        gr <- makeGRangesFromDataFrame(fread(f), keep.extra.columns=TRUE)
        if(any(!samples %in% colnames(mcols(gr)))){
            stop("Can not find provided sampleID in count data. Missing IDs: ",
                    paste(collapse=", ",
                            samples[!samples %in% colnames(mcols(gr))]))
        }
        gr[,samples]
    })

    # Check quality of external data. 
    stopifnot(all(granges(extCts[['k_j']]) == granges(extCts[['n_psi3']])))
    stopifnot(all(granges(extCts[['k_j']]) == granges(extCts[['n_psi5']])))
    stopifnot(all(granges(extCts[['k_theta']]) == granges(extCts[['n_theta']])))

    # With the external data, the k_j, n_psi3, and n_psi5 are junctions. 
    # The k_theta and n_theta are corresponding sites. 

    ### SR RANGES
    # SR_ranges is equivalent to our annotated junctions. 
    juncs <- FRASER:::annotateSpliceSite(extCts[["k_j"]])
    SR_ranges <- juncs[, c("startID", "endID")]

    ### NSR RANGES
    # NSR_ranges is equivalent to our annotated sites. To reannotate, we can use the spliced k_j junctions. 
    sites <- FRASER:::extractSpliceSiteCoordinates(juncs)
    sites <- data.frame(sites)[, c("seqnames", "start", "end", "spliceSiteID", "type")]
    sites$range <- paste0(sites$seqnames, ":", sites$start, "-", sites$end)
    sites <- sites[, c("range", "spliceSiteID", "type")]

    k_theta <- data.frame(extCts[["k_theta"]])[, c("seqnames", "start", "end", "strand")]
    k_theta$range <- paste0(k_theta$seqnames, ":", k_theta$start, "-", k_theta$end)

    sites <- merge(k_theta, sites, by = "range", all.x = TRUE, sort = FALSE)

    # Ensure that we have all of our info present. 
    stopifnot(all(!is.na(sites$spliceSiteID)))
    stopifnot(all(!is.na(sites$type)))

    sites_grange <- GRanges(
        seqnames = sites$seqnames,
        ranges = IRanges(start = sites$start, end = sites$end),
        strand = sites$strand,
        spliceSiteID = sites$spliceSiteID,
        type = sites$type
    )

    NSR_ranges <- sites_grange[, c("spliceSiteID", "type")]

    ### COUNTS
    CtsK_J     <- getCountMatrix(extCts[["k_j"]])
    CtsN_psi5  <- getCountMatrix(extCts[["n_psi5"]])
    CtsN_psi3  <- getCountMatrix(extCts[["n_psi3"]])
    CtsK_theta <- getCountMatrix(extCts[["k_theta"]])
    CtsN_theta <- getCountMatrix(extCts[["n_theta"]])

    ### FINAL OBJECTS
    nsr <- SummarizedExperiment(
            colData = data.frame(exAnno),
            assays = SimpleList(
                    rawCountsSS = CtsK_theta,
                    rawOtherCounts_theta = (CtsN_theta - CtsK_theta)),
            rowRanges= NSR_ranges
    )

    strand <- unique(exAnno$STRAND)
    strand_int <- 0
    if(length(strand) > 1){
        strand_int <- 0L
    } else if(strand == "no"){
        strand_int <- 0L
    } else if(strand == "yes"){
        strand_int <- 1L
    } else if(strand == "reverse"){
        strand_int <- 2L
    }
    fds <- new("FraserDataSet",
                name = fds_name,
                strandSpecific = strand_int,
                workingDir = fds_dir,
                colData = DataFrame(exAnno),
                assays = Assays(
                            SimpleList(
                                rawCountsJ = CtsK_J,
                                rawOtherCounts_psi5 = CtsN_psi5 - CtsK_J,
                                rawOtherCounts_psi3 = CtsN_psi3 - CtsK_J
                            )
                        ),
                nonSplicedReads = nsr,
                rowRanges = SR_ranges,
                elementMetadata = DataFrame(CtsK_J[,integer(0)]),
                metadata = list()
    )
    fds@colData$isExternal <- as.factor(TRUE)
    strandSpecific(fds) <- if(length(list(unique(exAnno$STRAND))) > 1) "no" else unique(exAnno$STRAND)

    ### RECOMPUTE PSI VALUES
    fds <- calculatePSIValues(fds)
    fds <- saveFraserDataSet(fds)
    
    ### RETURN FRASER OBJECT. 
    return(fds)
}
