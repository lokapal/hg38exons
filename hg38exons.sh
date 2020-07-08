#!/bin/sh
# script to obtain exons genome track for GRCh38/hg38 genome
# (C) Yuri Kravatsky, lokapal@gmail.com
# input from UCSC Genome Browser NCBI RefSeq Curated database
# output file: hg38.exons.bed
# Requirements: mysql client, Perl, R (biomaRt library)
#
# We will get exons from NCBI Refseq curated exons database
#RefSeq Curated – subset of RefSeq All that includes only those annotations whose accessions 
#begin with NM, NR, NP or YP. (NP and YP are used only for protein-coding genes on the mitochondrion; YP is used for human only.)
mysql --user=genome -N --host=genome-mysql.cse.ucsc.edu -A -D hg38 -e "select chrom, txStart, txEnd, strand, exonCount, exonStarts, exonEnds, name2 from ncbiRefSeqCurated order by chrom,txStart" > genes.hg38.txt
# Remove all exons located in alternate contigs, unlocalized sequences, unplaced sequences
./genes2exons.pl genes.hg38.txt
# Exons deduplication, full copies, overlapping exons merging
./gtf_ex_dedupe.pl genes.hg38.forward
./gtf_ex_dedupe.pl genes.hg38.reverse
sed -i '1d' genes.hg38.forward.dedupe
sed -i '1d' genes.hg38.reverse.dedupe
# Add GeneIDs from Ensemble
./add_ensemble.R genes.hg38.forward.dedupe
./add_ensemble.R genes.hg38.reverse.dedupe
#Merging back to the one file
cat genes.hg38.forward.dedupe.final genes.hg38.reverse.dedupe.final > hg38.exons.bed
sort -k1,1 -k2,2n -k3,3n hg38.exons.bed -o hg38.exons.bed
