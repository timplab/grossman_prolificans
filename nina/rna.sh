#!/bin/bash

datadir=/pym/Data/Nanopore/projects/prolificans/rna

if [ $1 == concat ] ; then
    mkdir -p $datadir/reads

    cat $datadir/raw/*1.fq.gz > $datadir/reads/5317_R1.fq.gz
    cat $datadir/raw/*2.fq.gz > $datadir/reads/5317_R2.fq.gz
fi

if [ $1 == trim ] ; then
    ##make adapters file. single adapter files don't have trailing newlines...
    cat ~/software/Trimmomatic-0.39/adapters/*fa > adapters.fa
    ##put in appropriate newlines
    sed -i -e 's/>/\'$'\n>/g' adapters.fa
    ##get rid of empty lines
    sed -i '/^$/d' adapters.fa 
    
    mkdir -p $datadir/trimmed
    
    java -jar ~/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE \
	 -threads 36 -phred33 \
	 $datadir/reads/5317_R1.fq.gz $datadir/$i/reads/5317_R2.fq.gz \
	 $datadir/trimmed/5317_fwd_paired.fq.gz $datadir/trimmed/5317_fwd_unpaired.fq.gz \
	 $datadir/trimmed/5317_rev_paired.fq.gz $datadir/trimmed/5317_rev_unpaired.fq.gz \
	 ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:30 MINLEN:36
fi

if [ $1 == trinity ] ; then
    mkdir -p $datadir/trinity

    Trinity \
	--seqType fq \
	--max_memory 250G \
	--CPU 54 \
	--left $datadir/trimmed/5317_fwd_paired.fq.gz \
	--right $datadir/trimmed/5317_rev_paired.fq.gz \
	--output $datadir/trinity
fi

asmdir=/pym/Data/Nanopore/projects/prolificans/st5317/final
gen=$asmdir/st5317.final.fasta
if [ $1 == align ] ; then
    mkdir -p $datadir/align

    hisat2-build $gen $asmdir/st5317.final
    hisat2 -p 36 \
	-x $asmdir/st5317.final \
	-1 $datadir/trimmed/5317_fwd_paired.fq.gz \
	-2 $datadir/trimmed/5317_rev_paired.fq.gz | \
	samtools view -@ 36 -b | \
	samtools sort -@ 36 -o $datadir/align/st5317.final.sorted.bam
    samtools index $datadir/align/st5317.final.sorted.bam
fi


if [ $1 == braker ] ; then
    mkdir -p $datadir/braker

    export GENEMARK_PATH=~/software/gmes_linux_64
    ~/software/BRAKER/scripts/braker.pl \
	--cores=36 \
	--gff3 \
	--genome=$gen \
	--species=prolif \
	--bam=$datadir/align/st5317.final.sorted.bam
fi


if [ $1 == busco ] ; then
    mkdir -p $datadir/busco
    mkdir -p $datadir/busco/braker
    mkdir -p $datadir/busco/trinity

    
    bedtools getfasta \
	     -fi $asmdir/st5317.final.fasta \
	     -bed $datadir/braker/braker.gff3 \
	     -fo $datadir/braker/braker.fasta
    seqkit rmdup -s < $datadir/braker/braker.fasta > $datadir/braker/braker_rmdup.fasta
    
    busco \
	-m transcriptome \
	-l sordariomycetes_odb10 \
	-i $datadir/braker/braker_rmdup.fasta \
	-o st5137_braker \
	--out_path $datadir/busco \
	-c 36 \
	-f

    busco \
	-m transcriptome \
	-l sordariomycetes_odb10 \
	-i $datadir/trinity/Trinity.fasta \
	-o st5137_trinity \
	--out_path $datadir/busco \
	-c 36 \
	-f
fi
