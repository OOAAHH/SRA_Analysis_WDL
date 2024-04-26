version 1.0

task cellranger_multi {
    input {
        String run_id
        File gene_expression_ref_tar_gz 
        File VDJ_ref_tar_gz
        File cellranger_tar_gz

        String output_csv_path
        String chemistry = "auto"

        Int? expect_cells
        Int? force_cells
        Boolean? check_library_compatibility
        Boolean? include_introns
        Int? r1_length
        Int? r2_length

        # used in GUI, an array of you files, an sample with this.GE and this.VDJ.
        # which means we need adjust our data model
        Array[File]? GE_fastq_file_paths
        Array[File]? VDJ_B_fastq_file_paths
        Array[File]? VDJ_T_fastq_file_paths
        # used for local, thats we defined you different file path, means directory.
        String? GE_fastq_file_directory
        String? VDJ_B_fastq_file_directory
        String? VDJ_T_fastq_file_directory

        String GE_run_id
        Int GE_run_lanes = 1

        String? VDJ_B_run_id
        Int? VDJ_B_run_lanes = 1

        String? VDJ_T_run_id
        Int? VDJ_T_run_lanes = 1

        String memory = "16 GB"
        String disk_space = "100 GB"
        Int cpu = 4
    }

    command <<<
        set -e

        mkdir -p cellranger
        tar -zxf ~{cellranger_tar_gz} -C cellranger --strip-components 1
        export PATH=$(pwd)/cellranger:$PATH

        mkdir -p genome_dir genome_VDJ_dir
        tar xf ~{gene_expression_ref_tar_gz} -C genome_dir --strip-components 1
        tar xf ~{VDJ_ref_tar_gz} -C genome_VDJ_dir --strip-components 1

        python3 <<CODE
        import csv
        import os
        from subprocess import check_call, CalledProcessError, DEVNULL, STDOUT

        # Setup CSV file for cellranger multi configuration
        csv_file = "~{output_csv_path}"
        with open(csv_file, 'w', newline='') as file:
            writer = csv.writer(file)

            # Gene-expression section
            writer.writerow(["[gene-expression]"])
            writer.writerow(["reference", "genome_dir"])
            writer.writerow(["chemistry", "~{chemistry}"])
            if ~{defined(expect_cells)}:
                writer.writerow(["expect-cells", ~{expect_cells}])
            if ~{defined(force_cells)}:
                writer.writerow(["force-cells", ~{force_cells}])
            if ~{defined(check_library_compatibility)}:
                writer.writerow(["check-library-compatibility", ~{check_library_compatibility}])
            if ~{defined(include_introns)}:
                writer.writerow(["include-introns", ~{include_introns}])

            # VDJ section
            writer.writerow(["[vdj]"])
            writer.writerow(["reference", "genome_VDJ_dir"])
            if ~{defined(r1_length)}:
                writer.writerow(["r1-length", ~{r1_length}])
                writer.writerow(["r2-length", ~{r2_length}])

            # Libraries section
            writer.writerow(["[libraries]"])
            writer.writerow(["fastq_id", "fastqs", "lanes", "feature_types"])

            # GEX part
            # used in GUI
            if ~{defined(GE_fastq_file_paths)}:
                fastq_file_paths = ["${sep='","' GE_fastq_file_paths"]
                fastq_dirs = set([os.path.dirname(f) for f in fastq_file_paths])
                writer.writerow(["~{GE_run_id}", "fastq_dirs", "~{GE_run_lanes}", "Gene_Expression"])
            # used for local
            elif ~{defined(GE_fastq_file_directory)}:
                writer.writerow(["~{GE_run_id}", "~{GE_fastq_file_directory}", "~{GE_run_lanes}", "Gene_Expression"])

            # VDJ part
            # VDJ B
            if ~{defined(VDJ_B_run_id)}:
                # used in GUI
                if ~{defined(VDJ_B_fastq_file_paths)}:
                    fastq_file_paths = ["${sep='","' VDJ_B_fastq_file_paths"]
                    fastq_dirs = set([os.path.dirname(f) for f in fastq_file_paths])
                    writer.writerow(["~{VDJ_B_run_id}", "fastq_dirs", "~{VDJ_B_run_lanes}", "VDJ-B"])
                # used for local
                elif ~{defined(VDJ_B_fastq_file_directory)}:
                    writer.writerow(["~{VDJ_B_run_id}", "~{VDJ_B_fastq_file_directory}", "~{VDJ_B_run_lanes}", "VDJ-B"])
            # VDJ T
            if ~{defined(VDJ_T_run_id)}:
                # used in GUI
                if ~{defined(VDJ_T_fastq_file_paths)}:
                    fastq_file_paths = ["${sep='","' VDJ_T_fastq_file_paths"]
                    fastq_dirs = set([os.path.dirname(f) for f in fastq_file_paths])
                    writer.writerow(["~{VDJ_T_run_id}", "fastq_dirs", "~{VDJ_T_run_lanes}", "VDJ-T"])
                # used for local
                elif ~{defined(VDJ_T_fastq_file_directory)}:
                    writer.writerow(["~{VDJ_T_run_id}", "~{VDJ_T_fastq_file_directory}", "~{VDJ_T_run_lanes}", "VDJ-T"])

        # RUN cellranger multi
        call_args = ['cellranger', 'multi', '--jobmode=local','--disable-ui']
        call_args.append('--localcores' + str(cpu))
        call_args.append('--id' + str(run_id))
        call_args.append('--csv' + ~{output_csv_path})
        print(' '.join(call_args))
        check_call(call_args)
        CODE
        # for output in .gz format
        tar -c -I pigz -f ~{run_id}_outs.tar.gz ~{run_id}/outs

    >>>

    output {
        File csv = "~{output_csv_path}"
        File multi_output = glob("./*.gz")
    }

    runtime {
        docker: "ooaahhdocker/python_pigz:1.0"
        memory: memory
        disk: disk_space
        cpu: cpu
    }
}
