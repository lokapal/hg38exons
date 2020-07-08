#!/usr/bin/Rscript
# script for adding Ensembl GeneIDs to exons list
# (C) Yuri Kravatsky, lokapal@gmail.com
# input genes.hg38.forward.dedupe (output from the script gtf_ex_dedupe.pl)
# Used R libraries:
# 1. biomaRt

args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (input file)\n", call.=FALSE)
                     }

# Import data from featureCounts, look to 3.prepcounts.sh
exonslist <- read.table(args[1], header=FALSE, row.names=NULL)

# Convert to matrix
#exonslist <- as.matrix(exonslist)

genenames <- exonslist$V5
ulist <- unique (exonslist$V5)

suppressPackageStartupMessages(require(biomaRt))

# Prepare gene table with some simple caching to avoid stressing the Ensembl server by many repeated runs 
genes.table = NULL

#replace the last extension to .cache
cachename <- gsub(pattern = "\\.*$", ".cache", args[1])

message("Retrieving genes table from Ensembl...")
mart <- useEnsembl(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")
#, mirror = "uswest")
#, mirror = "useast")
genetable <- getBM(filter="external_gene_name", attributes=c("ensembl_gene_id", "external_gene_name"), values=ulist, mart=mart, uniqueRows=TRUE)

# make a dictionary from the table "gene common name" "ensemble name"
gene_to_ens <- as.character(genetable$ensembl_gene_id)
names(gene_to_ens) <- as.character(genetable$external_gene_name)

# decode common gene names to ensemble names
ens_names <- gene_to_ens[genenames]
# treat empty cases - NAs
ens_names[is.na(ens_names)] <- genenames[is.na(ens_names)]

#add the last (6th) column to exonslist table
exonslist$V6=ens_names

#add extension ".final" to the argument of command string
#outfile <- gsub(".dedupe$", ".tsv", args[1])
outfile <- gsub('$', '.final', args[1])

write.table (exonslist, file = outfile, quote = FALSE, sep = "\t", col.names = FALSE, row.names = FALSE )
