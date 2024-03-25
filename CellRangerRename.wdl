version 1.0

task rename_fastq_files_based_on_size {
  input {
    Array[File] fastq_file_paths
    String sample_name
  }

  command <<<
    #!/bin/bash
    set -euo pipefail

    # 将输入文件路径存储到数组中
    FILES=(${~{sep=' ' fastq_file_paths}})

    # 获取文件大小并比较
    FILE_SIZE_1=$(stat -c%s "${FILES[0]}")
    FILE_SIZE_2=$(stat -c%s "${FILES[1]}")

    if [ $FILE_SIZE_1 -lt $FILE_SIZE_2 ]; then
      R1_FILE=${FILES[0]}
      R2_FILE=${FILES[1]}
    else
      R1_FILE=${FILES[1]}
      R2_FILE=${FILES[0]}
    fi

    # 构建新的文件名
    R1_NEW_FILENAME="${sample_name}_S1_L001_R1_001.fastq.gz"
    R2_NEW_FILENAME="${sample_name}_S1_L001_R2_001.fastq.gz"

    # 复制文件到新的文件名
    cp "$R1_FILE" "$R1_NEW_FILENAME"
    cp "$R2_FILE" "$R2_NEW_FILENAME"
  >>>

  output {
    Array[File] renamed_fastq_files = ["${sample_name}_S1_L001_R1_001.fastq.gz", "${sample_name}_S1_L001_R2_001.fastq.gz"]
  }

  runtime {
    docker: "ubuntu:latest"
  }
}

workflow example_workflow {
  input {
    Array[File] fastq_file_paths
    String sample_name
  }

  call rename_fastq_files_based_on_size {
    input:
      fastq_file_paths = fastq_file_paths,
      sample_name = sample_name
  }

  output {
    Array[File] renamed_files = rename_fastq_files_based_on_size.renamed_fastq_files
  }
}
