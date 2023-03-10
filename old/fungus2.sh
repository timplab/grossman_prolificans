#!/bin/bash

srcdir=~/Code/utils/marcc
datadir=/scratch/groups/mschatz1/cpowgs/fungus



if [ $1 == untar_v2 ] ; then
    mkdir -p $datadir/181108_nina_v2
    mkdir -p $datadir/181108_nina_v2/raw
    mkdir -p $datadir/181108_nina_v2/batch_logs
    ##sbatch --output=$datadir/181108_nina_v2/batch_logs/untar.out --job-name=ut_nina $srcdir/untar.scr $datadir/181108_nina_v2.tar.gz $datadir/181108_nina_v2
    ##shitty lustre file system caused untar to time out
    bash $srcdir/untar.scr $datadir/181108_nina_v2.tar.gz $datadir/181108_nina_v2
fi
    


if [ $1 == call_v2 ] ; then
    mkdir -p $datadir/181108_nina_v2/called
    mkdir -p $datadir/181108_nina_v2/call_logs
    mkdir -p $datadir/181108_nina_v2/call_done
    sbatch --array=0-1901 --job-name=nina_call --output=$datadir/181108_nina_v2/call_logs/nina_call.%A_%a.out $srcdir/bc_call_LSK109.scr $datadir/181108_nina_v2
fi



if [ $1 == fastq_v2 ] ; then
    mkdir -p $datadir/181108_nina_v2/fastqs/
    cat $datadir/181108_nina_v2/called/*/workspace/pass/barcode12/*.fastq > $datadir/181108_nina_v2/fastqs/st90853.fastq
    cat $datadir/181108_nina_v2/called/*/workspace/pass/barcode11/*.fastq > $datadir/181108_nina_v2/fastqs/st31.fastq
fi



if [ $1 == assemble_90853_v2 ] ; then
    mkdir -p $datadir/181108_nina_v2/st90853_assembly
    canu \
	-p st90853 -d $datadir/181108_nina_v2/st90853_assembly \
	-gridOptions="--time=22:00:00 --account=mschatz1 --partition=parallel" \
	genomeSize=39m \
	stopOnReadQuality=false \
	-nanopore-raw $datadir/181108_nina_v2/fastqs/st90853_bothruns_over3kb.fastq
fi



if [ $1 == assemble_31_v2 ] ; then
    mkdir -p $datadir/181108_nina_v2/st31_assembly
    canu \
	-p st31 -d $datadir/181108_nina_v2/st31_assembly \
	-gridOptions="--time=22:00:00 --account=mschatz1 --partition=parallel" \
	genomeSize=39m \
	stopOnReadQuality=false \
	-nanopore-raw $datadir/181108_nina_v2/fastqs/st31_bothruns_over3kb.fastq
fi


if [ $1 == merge_fq ] ; then
    cat $datadir/181108_nina_v2/fastqs/st90853.fastq $datadir/180827_nina_fungus2/fastqs/st90853.fastq > $datadir/181108_nina_v2/fastqs/st90853_bothruns.fastq
    cat $datadir/181108_nina_v2/fastqs/st31.fastq $datadir/180827_nina_fungus2/fastqs/st31.fastq > $datadir/181108_nina_v2/fastqs/st31_bothruns.fastq
fi
    
if [ $1 == long_fq ] ; then
    python ~/Code/utils/fastq_long.py -i $datadir/181108_nina_v2/fastqs/st31_bothruns.fastq -o $datadir/181108_nina_v2/fastqs/st31_bothruns_over3kb.fastq -l 3000
    python ~/Code/utils/fastq_long.py -i $datadir/181108_nina_v2/fastqs/st90853_bothruns.fastq -o $datadir/181108_nina_v2/fastqs/st90853_bothruns_over3kb.fastq -l 3000
fi

if [ $1 == assemble_90853_wtdbg2 ] ; then
    mkdir -p $datadir/181108_nina_v2/st90853_wtdbg2
    wtdbg2 -t 32 -i $datadir/181108_nina_v2/fastqs/st90853_bothruns_over3kb.fastq -fo $datadir/181108_nina_v2/st90853_wtdbg2/st90853_wtdbg2
    wtpoa-cns -t 32 -i $datadir/181108_nina_v2/wtdbg2/st90853_wtdbg2.ctg.lay.gz -fo $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta
fi

if [ $1 == assemble_31_wtdbg2 ] ; then
    mkdir -p $datadir/181108_nina_v2/st31_wtdbg2
    wtdbg2 -t 32 -i $datadir/181108_nina_v2/fastqs/st31_bothruns_over3kb.fastq -fo $datadir/181108_nina_v2/st31_wtdbg2/st31_wtdbg2
    wtpoa-cns -t 32 -i $datadir/181108_nina_v2/st31_wtdbg2/st31_wtdbg2.ctg.lay.gz -fo $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta
fi


if [ $1 == pilon ] ; then
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta
    
    mkdir -p $datadir/181108_nina_v2/pilon_st90853
    mkdir -p $datadir/181108_nina_v2/pilon_st31

    ##cp /work-zfs/mschatz1/cpowgs/fungus/illumina/st31* $datadir/181108_nina_v2/pilon_st31/
    ##cp /work-zfs/mschatz1/cpowgs/fungus/illumina/st90853* $datadir/181108_nina_v2/pilon_st90853/
    
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st31_wtdbg2.out --job-name=st31_wtdbg2 ./pilon.scr $datadir/181108_nina_v2/pilon_st31 $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta st31 wtdbg2
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st90853_wtdbg2.out --job-name=st90853_wtdbg2 ./pilon.scr $datadir/181108_nina_v2/pilon_st90853 $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta st90853 wtdbg2
fi

if [ $1 == pilon2 ] ; then
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta
    
    mkdir -p $datadir/181108_nina_v2/pilon_st90853
    mkdir -p $datadir/181108_nina_v2/pilon_st31

    ##cp /work-zfs/mschatz1/cpowgs/fungus/illumina/st31* $datadir/181108_nina_v2/pilon_st31/
    ##cp /work-zfs/mschatz1/cpowgs/fungus/illumina/st90853* $datadir/181108_nina_v2/pilon_st90853/
    
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st31_wtdbg2.out --job-name=st31_wtdbg2 ./pilon2.scr $datadir/181108_nina_v2/pilon_st31 $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta st31 wtdbg2
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st90853_wtdbg2.out --job-name=st90853_wtdbg2 ./pilon2.scr $datadir/181108_nina_v2/pilon_st90853 $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta st90853 wtdbg2
fi


if [ $1 == canu_pilon ] ; then
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta
    
    mkdir -p $datadir/181108_nina_v2/canu_pilon_st90853
    mkdir -p $datadir/181108_nina_v2/canu_pilon_st31

    cp /work-zfs/mschatz1/cpowgs/fungus/illumina/st31* $datadir/181108_nina_v2/canu_pilon_st31/
    cp /work-zfs/mschatz1/cpowgs/fungus/illumina/st90853* $datadir/181108_nina_v2/canu_pilon_st90853/
    
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st31_canu.out --job-name=st31_pilon ./pilon.scr $datadir/181108_nina_v2/canu_pilon_st31 $datadir/181108_nina_v2/st31_assembly/st31.contigs.fasta st31 canu
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st90853_canu.out --job-name=st90853_pilon ./pilon.scr $datadir/181108_nina_v2/canu_pilon_st90853 $datadir/181108_nina_v2/st90853_assembly/st90853.contigs.fasta st90853 canu
fi


if [ $1 == trim ] ; then
    for i in st31 st90853 ;
    do
	mkdir -p $datadir/181108_nina_v2/${i}_trimmed
	
	java -jar ~/software/Trimmomatic-0.38/trimmomatic-0.38.jar PE -threads 36 -phred33 \
	     $datadir/181108_nina_v2/canu_pilon_${i}/*R1*.gz $datadir/181108_nina_v2/canu_pilon_${i}/*R2*.gz \
	     $datadir/181108_nina_v2/${i}_trimmed/${i}_forward_paired.fq.gz $datadir/181108_nina_v2/${i}_trimmed/${i}_forward_unpaired.fq.gz \
	     $datadir/181108_nina_v2/${i}_trimmed/${i}_reverse_paired.fq.gz $datadir/181108_nina_v2/${i}_trimmed/${i}_reverse_unpaired.fq.gz \
	     ILLUMINACLIP:NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:30 MINLEN:36
    done
fi

if [ $1 == canu_pilon_trimmed ] ; then
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta
    
    mkdir -p $datadir/181108_nina_v2/canu_pilon_trimmed_st90853
    mkdir -p $datadir/181108_nina_v2/canu_pilon_trimmed_st31

    cp $datadir/181108_nina_v2/st31_trimmed/st31*paired*gz $datadir/181108_nina_v2/canu_pilon_trimmed_st31/
    cp $datadir/181108_nina_v2/st90853_trimmed/st90853*paired*gz* $datadir/181108_nina_v2/canu_pilon_trimmed_st90853/
    
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st31_canu.out --job-name=st31_pilon ./pilon.scr $datadir/181108_nina_v2/canu_pilon_trimmed_st31 $datadir/181108_nina_v2/st31_assembly/st31.contigs.fasta st31 canu
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st90853_canu.out --job-name=st90853_pilon ./pilon.scr $datadir/181108_nina_v2/canu_pilon_trimmed_st90853 $datadir/181108_nina_v2/st90853_assembly/st90853.contigs.fasta st90853 canu
fi

if [ $1 == pilon_trimmed ] ; then
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta
    ##sed -i -e 's/ /_/g' $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta
    
    mkdir -p $datadir/181108_nina_v2/pilon_trimmed_st90853
    mkdir -p $datadir/181108_nina_v2/pilon_trimmed_st31

    ##cp $datadir/181108_nina_v2/st31_trimmed/st31*paired*gz $datadir/181108_nina_v2/pilon_trimmed_st31/
    ##cp $datadir/181108_nina_v2/st90853_trimmed/st90853*paired*gz* $datadir/181108_nina_v2/pilon_trimmed_st90853/
    
    ##sbatch --output=$datadir/181108_nina_v2/batch_logs/st31_wtdbg2.out --job-name=st31_wtdbg2 ./pilon.scr $datadir/181108_nina_v2/pilon_trimmed_st31 $datadir/181108_nina_v2/st31_wtdbg2/st31.wtdbg2.contigs.fasta st31 wtdbg2
    ##sbatch --output=$datadir/181108_nina_v2/batch_logs/st90853_wtdbg2.out --job-name=st90853_wtdbg2 ./pilon.scr $datadir/181108_nina_v2/pilon_trimmed_st90853 $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta st90853 wtdbg2
    sbatch --output=$datadir/181108_nina_v2/batch_logs/st90853_wtdbg2.out --job-name=st90853_wtdbg2 ./pilon2.scr $datadir/181108_nina_v2/pilon_trimmed_st90853 $datadir/181108_nina_v2/st90853_wtdbg2/st90853.wtdbg2.contigs.fasta st90853 wtdbg2
fi


if [ $1 == bender_asm_assess ] ; then
    dboxdir=~/Dropbox/yfan/nina_fungus/assemblies
    echo assembly,num_contigs,n50,longest,shortest,total > $dboxdir/asmstats.csv
    for i in $dboxdir/*/*fasta ;
    do
	prefix=`basename $i .fasta`
	stats=`python2 ~/Code/utils/qc/asm_assess.py -i $i`
	echo $prefix,$stats >> $dboxdir/asmstats.csv
    done
fi


if [ $1 == align ] ; then
    ml samtools
    ##align nanopore reads to see if ctg14 in st31 needs to be broken
    mkdir -p $datadir/181108_nina_v2/align
    for i in st31 st90853 ;
    do
	minimap2 -a -x map-ont -t 36 $datadir/181108_nina_v2/$i/pilon_trimmed_${i}/${i}_wtdbg2.pilon.20.fasta $datadir/181108_nina_v2/fastqs/${i}_bothruns_over3kb.fastq | samtools view -bS | samtools sort -o $datadir/181108_nina_v2/align/$i.sorted.bam -T $datadir/181108_nina_v2/align/reads_$i.tmp
	samtools index $datadir/181108_nina_v2/align/$i.sorted.bam
    done
fi
