#########################################
# This is a WDL File                    #
# This file was formed for SRA to Fastq #
# Author: Sun Hao                       #
# Date: YYYY/MM/DD 2024/03/06           #
#########################################

version 1.0

task SRAtoFastq {
    input {
        String sra_file_paths
        Int ncpu = 4
        Int memory_gb = 8
    }

    command <<< 
        set -e
        mkdir -p fastq_output
    # 将单个路径转换为数组
        filePathsArray=("${sra_file_paths}")
        for sra_file in "${filePathsArray[@]}"; do
            fasterq-dump --split-3 ${sra_file} --threads ~{ncpu} -O ./fastq_output/ -v -p          #fasterq-dump $(basename ${sra_file_path}) --threads ~{ncpu} --outdir ./fastq_output/
        done
    >>>

    runtime {
        cpu: ncpu
        memory: "~{memory_gb} GB"
        #docker: "ncbi/sra-tools:latest"
        docker: "registry-vpc.miracle.ac.cn/biocontainers/sra-toolkit:v2.9.3dfsg-1b1-deb_cv1"
    }

    output {
        Array[File] fastq_files = glob("fastq_output/*.fastq")
    }
}

workflow ConvertSRAtoFastq {
    input {
        String sra_file_paths
    }

    call SRAtoFastq {
        input:
            sra_file_paths = sra_file_paths,
    }

    output {
        Array[File] fastq_files = SRAtoFastq.fastq_files
    }
}
