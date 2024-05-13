version 1.0

task MergeH5AD {
    input {
        Array[File] h5ad_files
        String output_filename = "merged.h5ad"
        String disk_space = "10 GB"
        Int cpu = 2
        String memory = "16 GB"
    }


    command <<<
        python3 <<CODE
        import os
        import shutil
        import scanpy as sc

        # List of input file paths, provided as WDL array
        h5ad_files = ["~{sep='", "' h5ad_files}"]

        # Process and rename files to avoid long paths
        processed_files = []
        for file_path in h5ad_files:
            basename = os.path.basename(file_path)
            shutil.copy(file_path, basename)  # Copy and rename to local
            processed_files.append(basename)

        # Function to ensure unique index by adding suffix
        def ensure_unique_index(adata, suffix):
            new_index = adata.obs.index.astype(str) + f"_{suffix}"
            # Check for duplicates and resolve by adding _1, _2, etc.
            unique_index = []
            seen = {}
            for idx in new_index:
                if idx not in seen:
                    unique_index.append(idx)
                    seen[idx] = 1
                else:
                    new_idx = f"{idx}_{seen[idx]}"
                    while new_idx in seen:
                        seen[idx] += 1
                        new_idx = f"{idx}_{seen[idx]}"
                    unique_index.append(new_idx)
                    seen[new_idx] = 1
            adata.obs.index = unique_index

        # Read, modify, merge, and save H5AD files
        adata_list = []
        for f in processed_files:
            if os.path.exists(f):
                adata = sc.read_h5ad(f)
                file_suffix = os.path.splitext(os.path.basename(f))[0]
                ensure_unique_index(adata, file_suffix)
                adata_list.append(adata)

        if adata_list:
            # Merge with outer join and add batch labels
            merged_adata = sc.concat(adata_list, join='outer', label='batch', keys=processed_files)
            merged_output_path = "~{output_filename}"
            merged_adata.write_h5ad(merged_output_path)

            # If merge was successful, delete original files to free up space
            if os.path.exists(merged_output_path):
                for f in processed_files:
                    os.remove(f)
                print("Original files deleted after successful merge.")
            else:
                print("Failed to create merged file, original files not deleted.")
        else:
            print("No valid H5AD files found for merging.")
        CODE
    >>>

    output {
        File merged_h5ad = "output/~{output_filename}"
    }

    runtime {
        docker: "ooaahhdocker/py39_scanpy1-10-1"
        cpu: cpu
        memory: memory
        disk: disk_space
    }
}
