# Amplivar-Blat v 1.1

## What does this app do?
This app takes a list of fastq files and runs amplivar.

Amplivar creates a list of unique reads and then performs alignment using Blat

## What are typical use cases for this app?
Analysis of cancer samples

## What data are required for this app to run?
* A indexed reference genome (`.tar.gz` format)
* A list of fastq files.
* A list of usual suspects
* A list of amplicon flanking sequences (by default this is the file saved in 001_ToolsReferenceData)
* Values for Minimum reported variant frequency (optional - default = 1%)
* Values for Minimum coverage for variant calling (optional - default is to leave blank)
* Values for Minimum number reads containing the variant allele (optional - default is to leave blank)

## What does this app output?
* A directory of bam files (in a folder called bam)
* A directory of bam files indexs
* A directory containing coverage reports
* A directory containing the read depth for each amplicon
* One folder per sample including all other files created during analysis

## How does this app work?
1. Clone the github repo
2. Unzips reference genome
3. Create 2 bit reference if not in referance genome input.
4. Install cutadapt, Java
5. Run BLAT server
6. Download the list of usual suspects
7. Run amplivar using -m Variant_Calling and arguments defined in inputs

## Custom modifications
* This app uses a copy of Amplivar (https://github.com/moka-guys/amplivar) modified to excluded variant calling (https://github.com/moka-guys/amplivar_blat)
* The app was made by the Viapath Genome Informatics section 