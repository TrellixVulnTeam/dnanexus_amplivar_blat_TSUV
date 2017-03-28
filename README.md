# Amplivar v 1.0

## What does this app do?
This app takes a list of fastq files and runs amplivar.

Amplivar creates a list of unique reads and then performs variant calling using VarScan (v2.4.3)

## What are typical use cases for this app?
Analysis of cancer samples

## What data are required for this app to run?
* A list of fastq files.
* A list of usual suspects (by default this is the file saved in 001_ToolsReferenceData)
* Values for Minimum reported variant frequency (optional - default = 20)
* Values for Minimum coverage for variant calling (optional - default is to leave blank)
* Values for Minimum number reads containing the variant allele (optional - default is to leave blank)
* Value for Keepfiles (required - default = 1)
  * 1= keep all files
  * 2= keep files required for reanalysis from checkpoint 1  
  * 3= keep only bam, vcf and log files and move the files into BAM, LOG, VCF files directories  

## What does this app output?
* A list of vcfs (in a folder called vcfs)
* One folder per sample including all the files created during analysis

## How does this app work?
1. Clone the github repo
2. Download reference genome
3. Create 2 bit reference
4. Install cutadapt, Java
5. Run BLAT server
6. Download the list of usual suspects
7. Run amplivar using -m Variant_Calling and arguments defined in inputs

## Custom modifications
* This app uses a fork of Amplivar modified to use an updated version of VarScan (https://github.com/moka-guys/amplivar)
* The app was made by the Viapath Genome Informatics section 