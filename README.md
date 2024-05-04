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

2024.4.22 : Added STARsolo WDL files, which could used in BD&SeqWell&Dropseq, without umitools.
  - ps. Set `--soloBarcodeReadLength=0` to skip the barcode and umi checks.

2024.4.23 : Function added
  - Increased the output of h5ad&bam files as much as possible.

2024.4.26 : Function added
  - For local fastq files, I had added `cellranger_singleFile.wdl`.

2024.4.28 ： Bugs fix
  - For VDJ files(SRA), we have to use parameters: "`--split-file` combined with `--include-technologies`".
  - ps. For SpaceRanger, we need to use parameters `--split-3`. Therefore, in the case of 10X, we need to choose the appropriate workflow for the specific situation.

2024.4.28 ：Added unplanned WDL files
  - 10X Cellranger multi WDL
