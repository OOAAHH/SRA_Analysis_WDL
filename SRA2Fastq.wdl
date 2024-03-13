#########################################
# This is a WDL File                    #
# This file was formed for SRA to Fastq #
# Author: Sun Hao                       #
# Date: YYYY/MM/DD 2024/03/06           #
#########################################

version 1.0

task SRAtoFastq {
    input {
        Array[String] sra_files
        Int ncpu = 4
        Int memory_gb = 8
    }

    command <<< 
        set -e
        mkdir -p fastq_output
        for sra_file in ~{sep=' ' sra_files}; do
            fasterq-dump ${sra_file} --threads ~{ncpu} --outdir ./fastq_output/
        done
    >>>

    runtime {
        cpu: ncpu
        memory: "~{memory_gb} GB"
        docker: "ghcr.io/stjude/abralab/sratoolkit:v3.0.0"
    }

    output {
        Array[File] fastq_files = glob("fastq_output/*.fastq")
    }
}

workflow ConvertSRAtoFastq {
    input {
        Array[File] sra_files
    }

    call SRAtoFastq {
        input:
            sra_files = sra_files,
    }

    output {
        Array[File] fastq_files = SRAtoFastq.fastq_files
    }
}
