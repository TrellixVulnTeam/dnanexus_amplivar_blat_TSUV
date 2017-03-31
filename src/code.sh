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

#read the api key as a variable
API_KEY=$(cat '/home/dnanexus/auth_key')

#make directory to hold input fastqs 
mkdir to_test
#make output folders
mkdir -p out/vcfs/vcfs/ out/amplivar_out/amplivar_out

#move all fastq inputs
for input in /home/dnanexus/in/fastqs/*; do if [ -d "$input" ]; then mv $input/* to_test/; fi; done

#move (and rename) usual suspects list
for file in /home/dnanexus/in/usual_suspects/*; do mv $file /home/dnanexus/usual_suspects.txt ; done

#
# Fetch and uncompress genome
#
dx download 001_ToolsReferenceData:Data/ReferenceGenomes/hs37d5.fasta-index.tar.gz --auth $API_KEY
tar -xvzf hs37d5.fasta-index.tar.gz

# clone amplivar
git clone https://github.com/moka-guys/amplivar.git

# install cutadapt
sudo pip install cutadapt

# make 2bit file
amplivar/bin/linux/faToTwoBit genome.fa genome.2bit

#set some variables used by amplivar
export TERM=xterm
export SHELL=/bin/bash

# start blat server
nohup /home/dnanexus/amplivar/bin/linux/gfServer start localhost 8800 /home/dnanexus/genome.2bit  &

#number of cores
cores=$(nproc --all)
cores=$(($cores-1))

#get the potential arguments for  Amplivar
 opts=("-k" "$keepfiles")

if [[ "$minfreq" != "" ]]
	then
	opts+=("-1" "$minfreq")
fi
if [[ "$mincov" != "" ]]
	then
	opts+=("-2" "$mincov")
fi
if [[ "$mincovvar" != "" ]]
	then
	opts+=("-3" "$mincovvar")
fi

# run amplivar
amplivar/bin/universal/amplivar_wrapper.sh -m VARIANT_CALLING -i /home/dnanexus/to_test  -o /home/dnanexus/out/amplivar_out/amplivar_out -s /home/dnanexus/usual_suspects.txt -p /home/dnanexus/amplivar/test/TruSeq_Cancer_primer-flanks.txt -d TRUSEQ -t $cores -g /home/dnanexus/genome.fa -x localhost -y 8800 "${opts[@]}"

##move the vcfs into a seperate output (potentially to feed into an annotator) 
for sample in /home/dnanexus/out/amplivar_out/amplivar_out/* ; do if [ -d "$sample" ]; then mv $sample/*.vcf /home/dnanexus/out/vcfs/vcfs/; fi; done

dx-upload-all-outputs --parallel
