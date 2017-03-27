#!/bin/bash
#

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail


update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

#
# Download inputs
#
dx-download-all-inputs

#make directory to hold input fastqs 
mkdir to_test
#make output folders
mkdir -p out/vcfs/vcfs/ out/amplivar_out/amplivar_out

#move all inputs
for input in /home/dnanexus/in/fastqs/*; do if [ -d "$input" ]; then mv $input/* to_test/; fi; done

ls to_test

#
# Fetch and uncompress genome
#
#dx download 001_ToolsReferenceData:Data/ReferenceGenomes/hs37d5.fasta-index.tar.gz
tar -xvzf hs37d5.fasta-index.tar.gz

# clone amplivar
git clone https://github.com/moka-guys/amplivar.git

# install cutadapt
sudo pip install cutadapt
# git clone https://github.com/marcelm/cutadapt.git
# cd cutadapt
# python setup.py install
# cd ..

# make 2bit file
amplivar/bin/linux/faToTwoBit genome.fa genome.2bit

export TERM=xterm
export SHELL=/bin/bash

# start blat server
nohup /home/dnanexus/amplivar/bin/linux/gfServer start localhost 8800 /home/dnanexus/genome.2bit  &

# run amplivar
amplivar/bin/universal/amplivar_wrapper.sh -m VARIANT_CALLING -i /home/dnanexus/to_test  -o /home/dnanexus/out/amplivar_out/amplivar_out -s /home/dnanexus/amplivar/test/TruSeq_Cancer_genotype-lookup.txt -p /home/dnanexus/amplivar/test/TruSeq_Cancer_primer-flanks.txt -d TRUSEQ -t 3 -g /home/dnanexus/genome.fa -x localhost -y 8800 -1 20 -k 1

##do VEP
for sample in /home/dnanexus/out/amplivar_out/amplivar_out/* ; do if [ -d "$sample" ]; then cp $sample/*.vcf /home/dnanexus/out/vcfs/vcfs/; fi; done

dx-upload-all-outputs --parallel
