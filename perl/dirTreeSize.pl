#!/usr/bin/perl -w

use strict;
use File::Find;

my %treeSize;

sub usage{
  printf ("Syntax error!\nUsage: dirTreeSize.pl <rootDir>\n");
  printf ("Example: dirTreeSize /tmp\n");
  exit(1);
}

sub printNameIfDir{
  #print "$_\n" if -d;
  #print "$_\n";
  if (-f){
    # check if an entry for the directory where the file belongs already exists in the hash
    $treeSize{$File::Find::dir}=0 unless ( exists( $treeSize{$File::Find::dir} ));
    $treeSize{$File::Find::dir}+= -s; # -s returns the size of the current file defined in $_
    #print "$File::Find::dir $_\n";
  }
}

if ($#ARGV+1 ne 1){
  usage();
}
my $rootDir=$ARGV[0];
find(\&printNameIfDir, $rootDir);

foreach my $k (sort keys %treeSize){
  printf ("Directory: %s \tSize:%s b\n",$k,$treeSize{$k});
}
