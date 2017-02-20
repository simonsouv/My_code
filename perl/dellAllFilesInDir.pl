#!/usr/bin/perl
use strict;

sub usage{
  printf ("Syntax error!\nUsage: dellAllFilesInDir <dirName> <'file extension to delete'>\n");
  printf ("Example: dellAllFilesInDir /tmp '.txt'\n");
  printf ("Example: dellAllFilesInDir /tmp '*'\n");
   exit(1);
}

if ($#ARGV+1 ne 2){ # $#ARGV returns the index of the last element in ARGV therefore add 1 to get the number of args
  usage();
}

my $workingDir=$ARGV[0];
my $extToDel=$ARGV[1];

# check directory exists and if not, quit
(-d $workingDir) or die("ERROR! $workingDir $!\n");

# modify the file extension to deal with the '*' case
$extToDel='*'.$extToDel unless ( $extToDel eq '*');
#printf ("Files to delete are %s\n",$extToDel);

my $code;
for (<$workingDir/$extToDel>){
  #print "delete file $_\n";
  $code="unlink";
  eval($code) or die("ERROR with command: $code on $_. $!\n");
}
