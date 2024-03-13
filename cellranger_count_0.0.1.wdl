version 1.0

workflow cellranger_count_workflow {
    input {
        Array[File] fastq_files
        File reference_genome
        String run_id
    }

    call run_cellranger_count {
        input:
            fastq_files = fastq_files,
            reference_genome = reference_genome,
            run_id = run_id
    }
}

task run_cellranger_count {
    input {
        Array[File] fastq_files
        File reference_genome
        String run_id
    }

    command {
        cellranger count \
            --id=${run_id} \
            --fastqs=${sep="," fastq_files} \
            --transcriptome=${reference_genome} \
            --localcores=8 \
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
