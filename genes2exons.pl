#!/usr/bin/perl
# script to remove non-chromosomal exons from the list downloaded from
# UCSC Genome Browser NCBI RefSeq Curated database
# (C) Yuri Kravatsky, lokapal@gmail.com

    use strict;
    use POSIX;

    my $ARGC=scalar @ARGV;

    if ($ARGC<1) { print "Usage: exons_dedupe.pl textfile\n";
                   exit (-1);
                  }

    my $infile=$ARGV[0];

    open (INP,"$infile") || die "Can't read \"$infile\": $!";
    my $basename=substr($infile,0,rindex($infile,"."));
    my $outfor=$basename.".forward";
    my $outrev=$basename.".reverse";

    open (OUTF,">$outfor") || die "Can't create \"$outfor\": $!";
    open (OUTR,">$outrev") || die "Can't create \"$outrev\": $!";

    while (<INP>) {
       chomp;
       chomp;
       if (length($_)<5) { next; }
       if ($_=~ m/^(\s+)?#/) { next; }                                                 # commented strings eliminated
       my @arr=split('\t');
       my $chr=$arr[0];
       if ($chr =~ m /_|-|CHRG|CHRH|CHRM|CHRKI/) { next; }
       my $beg=$arr[1];
       my $end=$arr[2];
       my $strand=$arr[3];
       my $name=$arr[7];
       my $exons=$arr[4];
       my $_=$arr[5];
       my @starts=split(',');
       my $ends=$arr[6];
       my $_=$arr[6];
       my @ends=split(',');
       if ($exons != scalar @starts) { print "Input inconsistent for gene $name, start number != number of records\n"; }
       if ($exons != scalar @ends)   { print "Input inconsistent for gene $name, ends  number != number of records\n"; }
       for (my $i=0;$i<$exons;$i++)  { if ($strand eq "+") { print OUTF "$chr\t$starts[$i]\t$ends[$i]\t$strand\t$name\n"; }
                                       if ($strand eq "-") { print OUTR "$chr\t$starts[$i]\t$ends[$i]\t$strand\t$name\n"; }
                                     }
                   }
   close (INP);
   close (OUTP);

   my $cmd="sort -k1,1 -k2,2n -k3,3n $outfor -o $outfor\n";
   `$cmd`;
   $cmd="sort -k1,1 -k2,2n -k3,3n $outrev -o $outrev\n";
   `$cmd`;
