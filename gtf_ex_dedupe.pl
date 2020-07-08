#!/usr/bin/perl
# script to deduplicate and merge overlapping exons from the list downloaded from
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
    my $outfile=$infile.".dedupe";

    open (OUTP,">$outfile") || die "Can't create \"$outfile\": $!";

    my $prevchr;
    my $prevbeg=0;
    my $prevend=0;
    my $prevname;
    my $prevstrand;

    my $prev=0;

    while (<INP>) {
       chomp;
       chomp;
       if (length($_)<5) { next; }
       if ($_=~ m/^(\s+)?#/) { next; }                                                 # commented strings eliminated
       my @arr=split('\t');
       if ($arr[0] eq $prevchr && $arr[1] >= $prevbeg  && $arr[2] <= $prevend && $arr[4] eq $prevname) { next; }
       if ($arr[0] eq $prevchr && $arr[1] >= $prevbeg  && $arr[2] <= $prevend && $arr[4] ne $prevname) { unless ($prevname =~ m/$arr[4]/) { $prevname .= ":$arr[4]"; }
                                                                                                         next; }
#       if ($arr[0] eq $prevchr && $arr[4] eq $prevname && $arr[1]<$prevbeg  &&  $arr[2]==$prevend)     { $prevbeg=$arr[1]; next; }
#       if ($arr[0] eq $prevchr && $arr[4] eq $prevname && $arr[1]==$prevbeg &&  $arr[2]>$prevend)      { $prevend=$arr[2]; next; }

# unrigorous filtering
       if ($arr[0] eq $prevchr && $arr[4] eq $prevname && $arr[1]<=$prevbeg  &&  abs($arr[2]-$prevend)<=11)   { $prevbeg=$arr[1]; 
                                                                                                                if ($arr[2]>$prevend) { $prevend=$arr[2]; }
                                                                                                                next; }

       if ($arr[0] eq $prevchr && $arr[4] eq $prevname && abs($arr[1]-$prevbeg)<=11 &&  $arr[2]>=$prevend)    { $prevend=$arr[2]; 
                                                                                                                if ($arr[1]<$prevbeg) { $prevbeg=$arr[1]; }
                                                                                                                next; }

       print OUTP "$prevchr\t$prevbeg\t$prevend\t$prevstrand\t$prevname\n";
       $prevchr=$arr[0];
       $prevbeg=$arr[1];
       $prevend=$arr[2];
       $prevstrand=$arr[3];
       $prevname=$arr[4];
                  }
   close (INP);
   print OUTP "$prevchr\t$prevbeg\t$prevend\t$prevstrand\t$prevname\n";
   close (OUTP);
   my $cmd="sort -k1,1 -k2,2n -k3,3n $outfile -o $outfile";
   `$cmd`;
