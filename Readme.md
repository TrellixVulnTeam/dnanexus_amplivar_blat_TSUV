# Amplivar-Blat v 1.6

## What does this app do?
This app takes an array of fastq files and runs amplivar.

Amplivar creates a list of unique reads and then performs alignment using Blat.

## What are typical use cases for this app?
Analysis of cancer samples

## What data are required for this app to run?
* A indexed reference genome (`.tar.gz` format)
* A list of fastq files.
* A list of usual suspects
* A list of amplicon flanking sequences (by default this is the file saved in 001_ToolsReferenceData)
* Value for minimum reported variant frequency as percentage of amplicon reads (optional - default = 1 (1%). If left blank uses amplivar default (5%))
* Value for minimum coverage for variant calling (optional - leaving blank uses amplivar default of 10 (default))
* Value for minimum number reads containing the variant allele (optional - leaving blank uses amplivar default of 5 (default))
* The branch of amplivar_blat to use. The master branch should be used for all production runs, and this is set as the default value. However this can be overwritten by settings in an Nexus workflow therefore this should always be specified in the dx run command.

## What does this app output?
* A directory of bam files (in a folder called bam)
* A directory of bam files indexes
* A directory containing the read depth for each amplicon (flanked file)
* One folder per sample including all other files created during analysis

## How does this app work?
1. Clone the amplivar github repo and checks out the specified branch
2. Downloads and unzips reference genome
3. If required makes 2 bit reference file.
4. Run BLAT server
5. Test the BLAT server is working using a example fasta file
6. converts the encoding of the flanking file using dos2unix, as this can cause the app to fail
7. Run amplivar using -m Variant_Calling and arguments defined in inputs
8. To speed up the upload of the many files produced by amplivar these are zipped on a sample by sample basis.

## Custom modifications
* This app uses a copy of Amplivar modified to exclude variant calling (https://github.com/moka-guys/amplivar_blat)
* The app was made by the Viapath Genome Informatics
