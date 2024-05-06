# SRA_Analysis_WDL
- An Auto Pipeline
- Robustness
- Designed for Bio-os

Here, we need a script, a program or an other things, to meet our need. 

What we need?
-----------------------
We have a platform built for fetch raw sequencing data to our system. Once the data is under our gover, we will get our pipline on woring. Given the complexity of the situation, our tools should be packaged as stand-alone toolkits, or they should take advantage of infrastructure that is readily available.


What we have,now
-----------------------
  - 10X Cellranger count WDL
  - 10X Cellranger ATAC count WDL
  - 10X Cellranger VDJ WDL
  - 10X Spaceranger WDL
  - 10X Cellranger multi WDL (for GEX + VDJ-T/VDJ-B or both of them)
  - SeqWell & Drop-seq & BD WDL (STARsolo)
  - SMART-seq WDL (STARsolo, too)
`Praise the god of STAR`


Update
-----------------------

2024.4.11 : Resolving compatibility issues
  - Lower versions of cellranger(2.9.6) are unable to handle newer 10X scRNA-seq data.
  - Added a way to externally import the cellranger package

2024.4.12 : The technical roadmap has been updated, and sra files are now reused using fasterq-dump
  - Docker pull: ooaahhdocker/python_pigz:1.0 with python3.9/pigz, which meet fastq file to fastq compressed file fast implementation.

2024.4.16 : Must come with full image information, slide number, etc.
  - For spaceranger, complete image information is a must, and the data provided by some authors is incomplete.

2024.4.22 : Added STARsolo WDL files, which could used in BD&SeqWell&Dropseq, without umitools.
  - ps. Set `--soloBarcodeReadLength=0` to skip the barcode and umi checks.
  - Docker pull: ooaahhdocker/starsolo2:3.0, with python3.9/scanpy1.10.1/star2.7.11 inside.
  - Attention!
    - To make the agreement between STARsolo and CellRanger even more perfect, you can add
    
    `args_dict['--genomeSAsparseD'] = ['3']`
    
    - CellRanger 3.0.0 use advanced filtering based on the EmptyDrop algorithm developed by Lun et al. This algorithm calls extra cells compared to the knee filtering, allowing for       cells that have relatively fewer UMIs but are transcriptionally different from the ambient RNA. In STARsolo, this filtering can be activated by:
    
    `args_dict['--soloCellFilter'] =['EmptyDrops_CR']`

2024.4.23 : Function added
  - Increased the output of h5ad&bam files as much as possible.

2024.4.26 : Function added
  - For local fastq files, I had added `cellranger_singleFile.wdl`.

2024.4.28 ： Bugs fix
  - For VDJ files(SRA), we have to use parameters: "`--split-file` combined with `--include-technologies`".
  - ps. For SpaceRanger, we need to use parameters `--split-3`. Therefore, in the case of 10X, we need to choose the appropriate workflow for the specific situation.

2024.4.28 ：Added unplanned WDL files
  - 10X Cellranger multi WDL

2024.5.4 ： Updated naming logic for files
  - The extent of the impact "SRA > fastq.gz"
