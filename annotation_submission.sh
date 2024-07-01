#!/bin/bash

datadir=/pym/Data/Nanopore/projects/prolificans

if [ $1 == sqn ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix jhhlp \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=JHH-5317]" \
	-t $datadir/nina_annot/st5317.sbt \
	-i $datadir/nina_names/st5317.final2-new_names.fasta \
	-f $datadir/nina_annot/st5317.final2.fasta.functional_note.pseudo_label.gff \
	-o $datadir/nina_annot/st5317.sqn
fi

if [ $1 == st31 ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix SC321 \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=3.1]" \
	-t $datadir/nina_annot/st31.sbt \
	-i $datadir/nina_names/st31.final2-new_names.fasta \
	-f $datadir/nina_annot/st31.final2.fasta.functional_note.pseudo_label.gff \
	-o $datadir/nina_annot/st31.sqn
fi

if [ $1 == st90853 ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix SC322 \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=90853]" \
	-t $datadir/nina_annot/st90853.sbt \
	-i $datadir/nina_names/st90853.final2-new_names.fasta \
	-f $datadir/nina_annot/st90853.final2.fasta.functional_note.pseudo_label.gff \
	-o $datadir/nina_annot/st90853.sqn
fi

if [ $1 == add_pseudo ] ; then
   for i in st90853 st31 st5317 ;
   do
       python ./add_pseudo.py \
	      -g $datadir/nina_annot/$i.final2.fasta.functional_note.pseudo_label.gff \
	      -v $datadir/nina_annot/$i.val \
	      -o $datadir/nina_annot/$i.final2.fasta.functional_note.pseudo_label.yfan.gff
   done
fi
   
if [ $1 == st5317_pseudo ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix jhhlp \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=JHH-5317]" \
	-t $datadir/nina_annot/st5317.sbt \
	-i $datadir/nina_names/st5317.final2-new_names.fasta \
	-f $datadir/nina_annot/st5317.final2.fasta.functional_note.pseudo_label.yfan.gff \
	-o $datadir/nina_annot/st5317.sqn
fi

if [ $1 == st31_pseudo ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix SC321 \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=3.1]" \
	-t $datadir/nina_annot/st31.sbt \
	-i $datadir/nina_names/st31.final2-new_names.fasta \
	-f $datadir/nina_annot/st31.final2.fasta.functional_note.pseudo_label.yfan.gff \
	-o $datadir/nina_annot/st31.sqn
fi

if [ $1 == st90853_pseudo ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix SC322 \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=90853]" \
	-t $datadir/nina_annot/st90853.sbt \
	-i $datadir/nina_names/st90853.final2-new_names.fasta \
	-f $datadir/nina_annot/st90853.final2.fasta.functional_note.pseudo_label.manual.gff \
	-o $datadir/nina_annot/st90853.sqn
fi

if [ $1 == add_gene_pseudo ] ; then
   for i in st90853 st31 st5317 ;
   do
       python ./add_gene_pseudo.py \
	      -g $datadir/nina_annot/$i.final2.fasta.functional_note.pseudo_label.yfan.gff \
	      -o $datadir/nina_annot/$i.final2.fasta.functional_note.pseudo_label_gene.yfan.gff
   done
fi

if [ $1 == st5317_gene_pseudo ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix jhhlp \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=JHH-5317]" \
	-t $datadir/nina_annot/st5317.sbt \
	-i $datadir/nina_names/st5317.final2-new_names.fasta \
	-f $datadir/nina_annot/st5317.final2.fasta.functional_note.pseudo_label_gene.yfan.gff \
	-o $datadir/nina_annot/st5317.sqn
fi

if [ $1 == st31_gene_pseudo ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix SC321 \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=3.1]" \
	-t $datadir/nina_annot/st31.sbt \
	-i $datadir/nina_names/st31.final2-new_names.fasta \
	-f $datadir/nina_annot/st31.final2.fasta.functional_note.pseudo_label_gene.yfan.gff \
	-o $datadir/nina_annot/st31.sqn
fi

if [ $1 == st90853_gene_pseudo ] ; then
    ~/software/table2asn \
	-M n -Z -J -c w \
	-euk \
	-locus-tag-prefix SC322 \
	-augustus-fix \
	-gaps-min 5 \
	-gaps-unknown 100 \
	-l paired-ends \
	-j "[organism=Lomentospora prolificans] [isolate=90853]" \
	-t $datadir/nina_annot/st90853.sbt \
	-i $datadir/nina_names/st90853.final2-new_names.fasta \
	-f $datadir/nina_annot/st90853.final2.fasta.functional_note.pseudo_label_gene.manual.gff \
	-o $datadir/nina_annot/st90853.sqn
fi
