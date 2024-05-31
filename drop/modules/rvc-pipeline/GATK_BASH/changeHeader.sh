#!/bin/bash

# helper file for RVC snakemake rule changeHeader

# 1 {input.bam}
# 2 {input.bai}
# 3 {params.sample}
# 4 {output.bam}
# 5 {output.bai}
# 6 {output.newHeader}
input_bam=$1
input_bai=$2
sample=$3
output_bam=$4
output_bai=$5
output_newHeader=$6


SM_internalHeader=""
PL_internalHeader=""
samtools view -H $input_bam |grep "^@RG" |grep SM |head -1|
while read header ; do
    for i in $header; do
        if [[ $i == "SM:"* ]]; then
            SM_internalHeader=${i:3}
        fi
        if [[ $i == "PL:"* ]]; then
            PL_internalHeader=${i:3}
        fi
    done

    if [[ $SM_internalHeader == $sample && $PL_internalHeader != "" ]]; then
        echo "Internal Header $SM_internalHeader matches $sample"
        echo "Internal Header is designated: $SM_internalHeader"
        echo "SampleID is $sample"
        ln -s -f  $input_bam $output_bam
        ln -s -f  $input_bai $output_bai
        echo "Done Linking files"
		samtools view -H $input_bam > $output_newHeader
    else
        if [[ $SM_internalHeader != $sample ]]; then
            echo "WARNING"
            echo "Internal Header is designated: $SM_internalHeader"
            echo "SampleID is $sample"
            echo "Forcing $SM_internalHeader to match $sample"

            # sed using regEx in place substitiute 'SM:' followed by any thing that isn't tab or newLine. and then replace it with the sampleID and the delimiter (tab or newLine) that matched in the 1st expression.
            samtools view -H $input_bam > $output_newHeader
            sed -E -i "s/(SM:[^\t|\n]*)(\t|\n*)/SM:${sample}\2/" ${output_newHeader}
        fi
        if [[ $PL_internalHeader == "" ]]; then
            echo "WARNING"
            echo "Internal PL Header is not designated: $PL_internalHeader"
            echo "PL cannot be empty. Using a Dummy: dummyPL "
            echo "Forcing $PL_internalHeader to dummyPL"

            # sed using regEx in place substitiute '@RG' with @RG\tPL:dummyPL
            samtools view -H $input_bam > $output_newHeader
            sed -E -i "s/^@RG/@RG\tPL:dummyPL/" ${output_newHeader}
        fi
        samtools reheader $output_newHeader $input_bam > $output_bam
        samtools index -b $output_bam
    fi
    echo "new header can be found here:$output_newHeader"
done
