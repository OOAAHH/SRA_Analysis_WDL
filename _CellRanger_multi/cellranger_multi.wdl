version 1.0
# for cellranger multi
task cellranger_multi {
    input {
        # reference
        File gene_expression_ref_tar_gz
        File VDJ_ref_tar_gz
        # software
        File cellranger_tar_gz

        # actually, its name
        String output_csv_path

        # optional for cellranger multi
        # chemistry, auto or v2,v3
        String chemistry = "auto"
        # expect_cells
        Int? expect_cells
        # force_cells
        Int? expect_cells
        # ~{check_library_compatibility}
        Boolean? check_library_compatibility
        # include_introns
        Boolean? include_introns

        # VDJ optional
        Int? r1-length
        Int? r2-length

        # library optional
        # fastqs
        Array[File] GE_fastq_file_paths
        Array[File] VDJ_fastq_file_paths

        String GE_run_id
        Int GE_run_lanes = 1

        String? VDJ_B_run_id
        Int? VDJ_B_run_lanes

        String? VDJ_T_run_id
        Int? VDJ_T_run_lanes
    }
    command {

        # Unpack the CellRanger software to a local directory
        mkdir cellranger
        tar -zxf ~{cellranger_tar_gz} -C cellranger --strip-components 1
        # Set PATH to include CellRanger binaries
        export PATH=$(pwd)/cellranger:$PATH

        # gene_expression_ref
        mkdir -p genome_dir
        tar xf ~{gene_expression_ref_tar_gz} -C genome_dir --strip-components 1

        # VDJ_expression_ref
        mkdir -p genome_VDJ_dir
        tar xf ~{VDJ_ref_tar_gz} -C genome_VDJ_dir --strip-components 1

        python3 <<CODE
        import csv
        csv_file = "~{output_csv_path}"

        with open(csv_file, mode='w', newline='') as file:
            writer = csv.writer(file)

            # Write the [gene-expression] section
            writer.writerow(["[gene-expression]"])
            writer.writerow(["reference", "genome_dir"])
                # optinal
            writer.writerow(["chemistry", "~{chemistry}"])
            if '~{expect_cells}' =! '' :
                writer.writerow(["expect-cells", "~{expect_cells}"])

            if '~{force_cells}' =! '' :
                writer.writerow(["force-cells", "~{force_cells}"])

            writer.writerow(["no-secondary", "true"])

            if '~{check_library_compatibility}' =! '' :
                writer.writerow(["check-library-compatibility", "~{check_library_compatibility}"])

            if '~{include_introns}' =! '' :
                writer.writerow(["include-introns", "~{include_introns}"])
            #writer.writerow(["min-assignment-confidence", "~{min_assignment_confidence}"])
            #writer.writerow(["cmo-set", "~{cmo_set}"])
            #writer.writerow(["barcode-sample-assignment", "~{barcode_sample_assignment}"])

            # VDJ
            writer.writerow(["[vdj]"])
            writer.writerow(["reference", "genome_VDJ_dir"])
                # optinal
            if '~{r1-length}' =! '' :
                writer.writerow(["r1-length", "~{r1-length}"])
                writer.writerow(["r2-length", "~{r2-length}"])

            # Libraries
            writer.writerow(["[libraries]"])

                # Write the [gene-expression] section fastq_dirs
                # Convert the WDL Array[File] input to a Python list
            GE_fastq_file_paths = ["~{sep='","' GE_fastq_file_paths}"]
            GE_fastq_dirs = set([os.path.dirname(f) for f in GE_fastq_file_paths])
            print(GE_fastq_dirs)

                # Write the [VDJ] section fastq_dirs
                # Convert the WDL Array[File] input to a Python list
            VDJ_fastq_file_paths = ["~{sep='","' VDJ_fastq_file_paths}"]
            VDJ_fastq_dirs = set([os.path.dirname(f) for f in VDJ_fastq_file_paths])
            print(VDJ_fastq_dirs)

            writer.writerow(["fastq_id", "fastqs", "lanes", "feature_types"])
            writer.writerow(["~{GE_run_id}", "GE_fastq_dirs", "~{GE_run_lanes}", "Gene_Expression"])
            #
            if '~{VDJ_B_run_id}' =! '' :
                writer.writerow(["~{VDJ_B_run_id}", "VDJ_fastq_dirs", "~{VDJ_B_run_lanes}", "VDJ-B"])
            if '~{VDJ_T_run_id}' =! '' :
                writer.writerow(["~{VDJ_T_run_id}", "VDJ_fastq_dirs", "~{VDJ_T_run_lanes}", "VDJ-T"])
        CODE

    }

    output {
        File csv = "~{output_csv_path}"
    }

    runtime {
        docker: "ooaahhdocker/py39_scanpy1-10-1"
        memory: memory
        disk: disk_space
        cpu: num_cpu
    }
}
