#########################################
# This is a WDL File                    #
# This file was formed for CellRanger   #
# Author: Sun Hao                       #
# Date: YYYY/MM/DD 2024/03/13           #
#########################################

version 1.0

task run_cellranger_count {
    input {
        File fastq_file_paths
        #String fastq_file_paths
        File reference_genome
        #String reference_genome
        String run_id
    }

    command {
        set -e
        ls -l ~{fastq_file_paths}
        cellranger count --id ~{run_id} \
            --fastqs=~{fastq_file_paths} \
            --transcriptome=~{reference_genome} \
            --localcores=8 \
            --jobmode=local \
            --localmem=32
    }

    output {
        File output_count_directory = "~{run_id}/outs"
        File output_metrics_summary = "~{run_id}/outs/metrics_summary.csv"
        File output_web_summary = "~{run_id}/outs/web_summary.html"
    }

    runtime {
        docker: "nfcore/cellranger:7.2.0"
        cpu: "8"
        memory: "32 GB"
        disk: "local-disk 300 HDD"
    }
}

workflow cellranger_count_workflow {
    input {
        File fastq_file_paths
        File reference_genome
        String run_id
    }

    call run_cellranger_count {
        input:
            fastq_file_paths = fastq_file_paths,
            reference_genome = reference_genome,
            run_id = run_id
    }
}

