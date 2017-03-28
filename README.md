# Amplivar v 1.0

## What does this app do?
This app takes a list of fastq files and runs amplivar.

Amplivar creates a list of unique reads and then performs variant calling using VarScan (v2.4.3)

## What are typical use cases for this app?
Analysis of cancer samples

## What data are required for this app to run?
A list of fastq files.

## What does this app output?
* A list of vcfs (in a folder called vcfs)
* One folder per sample including all the files created during analysis

## Custom modifications
* This app uses a fork of Amplivar (modified to use an updated version of VarScan)
* The app was made by the Viapath Genome Informatics section 

## How does this app work?
1. Clone the github repo
2. Download reference genome
3. Create 2 bit reference
4. Install cutadapt, Java
5. Run BLAT server
6. Run amplivar using -m Variant_Calling