#########################################
# This is a WDL File                    #
# This file was formed for SRA to Fastq #
# Author: Sun Hao                       #
# Date: YYYY/MM/DD 2024/03/06           #
#########################################

version 1.0

task SRAtoFastq {
    input {
        File sra_file_paths
        Int ncpu = 4
        Int memory_gb = 8
    }

    command { 
        fasterq-dump -vvv -x ${sra_file_paths} -O ./ 
    }

    runtime {
        cpu: ncpu
        memory: "~{memory_gb} GB"
        disks: "local-disk 300 HDD"
        docker: "registry-vpc.miracle.ac.cn/biocontainers/sra-toolkit:v2.9.3dfsg-1b1-deb_cv1"
    }

    output {
        Array[File] fastq_files = glob("./*.fastq")
    }
}

workflow ConvertSRAtoFastq {
    input {
        String sra_file_paths
    }

    call SRAtoFastq {
        input:
            sra_file_paths = sra_file_paths
    }

    output {
        Array[File] fastq_files = SRAtoFastq.fastq_files
    }
}
