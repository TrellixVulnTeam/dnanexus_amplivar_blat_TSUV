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
dx-download-all-inputs --except ref_genome --parallel

#make directory to hold input fastqs 
mkdir to_test
#make output folders
mkdir -p out/bams/bams/ out/amplivar_out/amplivar_out out/coverage_raw/coverage_raw out/bam_bai/bams amplivar_temp

#move all fastq inputs
for input in /home/dnanexus/in/fastqs/*; do if [ -d "$input" ]; then mv $input/* to_test/; fi; done

# clone amplivar
git clone https://github.com/moka-guys/amplivar_blat.git
cd amplivar_blat
git checkout $git_branch
cd ..

# add miniconda to path to ensure correct installation of python is used.
PATH=/home/dnanexus/miniconda2/bin:$PATH

# install cutadapt - pip stopped working so use conda, specifically bioconda channel
#sudo pip install cutadapt
#conda config --add channels bioconda
#conda install -c bioconda cutadapt=1.14 xopen=0.3.2=py27_0

# create directory for reference genome, un-package reference genome
mkdir genome
dx cat "$ref_genome" | tar zxvf - -C genome  
genome_file=`ls /home/dnanexus/genome/*.fa`

# Check if 2bit file exists
bitfile=(`find ./genome/ -maxdepth 1 -name "*.2bit"`)
# if 2bit file does not exist (len of name = 0) create 2bit file 
if [ ${#bitfile[@]} = 0 ]; then 
	echo "generating 2bit"
	amplivar_blat/bin/linux/faToTwoBit *.fa genome.2bit
fi

#set some variables used by amplivar
export TERM=xterm
export SHELL=/bin/bash

# start blat server
nohup /home/dnanexus/amplivar_blat/bin/linux/gfServer start localhost 8802 /home/dnanexus/genome/*.2bit &
sleep 100
/home/dnanexus/amplivar_blat/bin/linux/gfClient -out=pslx -nohead localhost 8802 "" test_blat_server.fna test_blat_server.blat.pslx 
cat test_blat_server.blat.pslx
rm test_blat_server.blat.pslx

#number of cores
cores=$(nproc --all)
cores=$(($cores-1))

# intiate and get the optional usual suspects file
echo $ampliconflank_path
echo $usual_suspects_path
if [ -f $usual_suspects_path ]
	then
	suspects="-s $usual_suspects_path"
else suspects=""
fi

echo $suspects
echo $minfreq
echo $mincov
echo $mincovvar

# intiate and get the potential arguments for  Amplivar
 opts=""

if [[ "$minfreq" != "" ]]
	then
	opts="$opts -1 $minfreq"
fi
if [[ "$mincov" != "" ]]
	then
	opts="$opts -2 $mincov"
fi
if [[ "$mincovvar" != "" ]]
	then
	opts="$opts -3 $mincovvar"
fi

# convert flanking file from dos2unix (just incase)
dos2unix $ampliconflank_path

# run amplivar-blat
amplivar_blat/bin/universal/amplivar_wrapper.sh -m VARIANT_CALLING -i /home/dnanexus/to_test -o /home/dnanexus/amplivar_temp $suspects -p $ampliconflank_path -d TRUSEQ -t $cores -g $genome_file -x localhost -y 8802 $opts

# view ampliva logs - for trouble shooting
# for sample in /home/dnanexus/out/amplivar_out/amplivar_out/* ;
# do cat $sample/*_L001.log
# done


## move the bams, coverage reports and coverage data into a seperate outputs (potentially to feed into an annotator) 
for sample in /home/dnanexus/amplivar_temp/* ; 
do if [ -d "$sample" ]; then 
samplename=$(basename $sample)
tar -zcvf /home/dnanexus/out/amplivar_out/amplivar_out/$samplename.amplivar_out.tar.gz $sample
mv $sample/*.blat.bam /home/dnanexus/out/bams/bams/ 
mv $sample/*.bam.bai out/bam_bai/bams/
mv $sample/flanked/*_flanked.txt out/coverage_raw/coverage_raw/;
fi; done


dx-upload-all-outputs --parallel
