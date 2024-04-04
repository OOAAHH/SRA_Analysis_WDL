version 1.0
task ExtractFASTQ {
    input {
        File sra_file
        File sratoolkit_tar_gz
        String sample_name
        String memory = "8 GB"
        # Disk space in GB
        String disk_space = "300 GB"
        # Number of cpus per cellranger job
        Int cpu = 8
    }

    command {
        set -e
        mkdir -p sratoolkit
        tar -xzf ~{sratoolkit_tar_gz} -C sratoolkit --strip-components 1
        export PATH=$(pwd)/sratoolkit/bin:$PATH

        python3 <<CODE
        import os
        from subprocess import check_call

        sra_file = "~{sra_file}"
        cpu = ~{cpu}
        call_args = [
            'fasterq-dump',
            '--split-files',
            '-e', str(cpu),
            sra_file
        ]
        print('Executing:', ' '.join(call_args))
        check_call(call_args)
        CODE

    }

    output {
        Array[File] fastq_files = glob("*.fastq")
    }


    runtime {
        docker: "python:3.9.19-slim-bullseye"
        cpu: cpu
        memory: memory
        disk: disk_space
    }
}


task rename_fastq_files_based_on_size {
  input {
    Array[File] fastq_file_paths
    String sample_name
    String disk_space = "150 GB"
    Int cpu = 8 
  }

    command <<<
        python3 <<CODE
        import os
        import shutil
    
        # Convert file paths from WDL array to Python list
        files = ["~{sep='", "' fastq_file_paths}"]
        sample_name = "~{sample_name}"
    
        # Calculate file sizes and sort them
        file_sizes = [(f, os.path.getsize(f)) for f in files]
        file_sizes.sort(key=lambda x: x[1])
    
        # Initialize variables to hold file paths
        i1_file, r1_file, r2_file = None, None, None
    
        # Determine the number of files and assign accordingly
        if len(files) == 2:
            r1_file, r2_file = file_sizes[0][0], file_sizes[1][0]
        elif len(files) == 3:
            i1_file, r1_file, r2_file = file_sizes[0][0], file_sizes[1][0], file_sizes[2][0]
    
        # Define new filenames
        i1_new_filename = f"{sample_name}_S1_L001_I1_001.fastq" if i1_file else None
        r1_new_filename = f"{sample_name}_S1_L001_R1_001.fastq"
        r2_new_filename = f"{sample_name}_S1_L001_R2_001.fastq"
    
        # Copy and rename files
        if i1_file:
            shutil.copy2(i1_file, i1_new_filename)
        shutil.copy2(r1_file, r1_new_filename)
        shutil.copy2(r2_file, r2_new_filename)
    
        # Output new filenames for verification
        if i1_new_filename:
            print(i1_new_filename)
        print(r1_new_filename)
        print(r2_new_filename)
        CODE
        for fastq in *.fastq; do
            gzip "$fastq"
        done
    >>>

  output {
    Array[File] renamed_fastq_files = glob("./*_L001_*_001.fastq.gz")
    String sample_name_out = sample_name
  }

  runtime {
    docker: "python:3.9.19-slim-bullseye"
    cpu: cpu
    disk: disk_space
  }
}




workflow ProcessSRA {
    input {
        File sra_file
        File sratoolkit_tar_gz
        String sample_name
        String memory = "8 GB"
        String disk_space = "300 GB"
        Int cpu = 8
    }

    call ExtractFASTQ {
        input:
            sra_file = sra_file,
            sratoolkit_tar_gz = sratoolkit_tar_gz,
            sample_name = sample_name,
            cpu = cpu,
            memory = memory,
            disk_space = disk_space
    }

    call rename_fastq_files_based_on_size {
        input:
            fastq_file_paths = ExtractFASTQ.fastq_files,
            sample_name = sample_name,
            disk_space = "300 GB",
            cpu = 1
    }

    output {
        Array[File] gz_fastq_files = rename_fastq_files_based_on_size.renamed_fastq_files
    }
}
