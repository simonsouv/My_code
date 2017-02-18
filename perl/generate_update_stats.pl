#!/usr/bin/perl -w
use strict;

# script parses a file resulting from SYBASE sql execution with option "set option show_missing_stats on"
#

# uncomment the 4 lines below if you want to print the args passed to the script
#print "Args list: ";
#foreach my $currentArg (@ARGV){
#  printf ("%s ",$currentArg);
#}
printf ("\nNumber of args passed: %s\n",$#ARGV+1);

#Make sure 2 arguments are passed to the script otherwise quit
if ( $#ARGV+1 ne 2){
  printf ("Syntax error\nusage: generate_update_stats.pl inputFile outputFile\n");
  printf ("inputFile is the output of SQL script executed with command dbcctraceon(3604);set option show_missing_stats on;set nodata on\n");
  printf ("outputFile is the SQL script that will contain the update statistics command to execute\n");
  exit(-1);
}

#my $inputFilename='/cygdrive/d/Tmp/BBVA/cases/slowness_counterpart_gerson/slow_ctpart_rdb.10431_filtered.log';
#my $outputFilename='/cygdrive/d/Tmp/BBVA/cases/slowness_counterpart_gerson/update_statistics.sql';
my $inputFilename=$ARGV[0];
my $outputFilename=$ARGV[1];

#check inputfile exists and output file does not exist
(-e $inputFilename) or die "Error -- input file $inputFilename: $!\n";
(! -e $outputFilename) or die "Error -- output file $outputFilename already exists, cannot overwrite\n";

printf ("input file: %s\noutput file: %s\n",$inputFilename,$outputFilename);
open my $inputFileHandle,'<',$inputFilename;
open my $outputFileHandle,'>',$outputFilename;

while(  defined(my $currentLine=<$inputFileHandle>) ){
  if ( $currentLine =~ m/^NO STATS on column/ &&  $currentLine !~ m/tempdb/ ){ #NO STATS on column means statistics is missing on one column
    chomp($currentLine);
	# get the last element of the current line representing the table and column missing statistics
	# the last element has pattern TABLE_NAME.COLUMN_NAME so we split again based on the .
	my @tabAndCol = split(/\./,(split(/ /,$currentLine))[-1]); # get the last element of the current line representing the table and column missing statistics
	printf ($outputFileHandle "print 'execute update statistics %s(%s)'\ngo\n", $tabAndCol[0], $tabAndCol[1]);
	printf ($outputFileHandle "update statistics %s(%s)\ngo\n", $tabAndCol[0], $tabAndCol[1]);
  }
  if ( $currentLine =~ m/^NO STATS on density set / &&  $currentLine !~ m/tempdb/ ){ ##NO STATS on density set  means statistics is missing on a set of columns
    chomp($currentLine);
	my $tabAndCol = (split(/ for /,$currentLine))[-1]; # get the last element of the current line representing the table and the set of column
	$tabAndCol =~ s/=\{/(/;
	$tabAndCol =~ s/\}/)/;
	printf ($outputFileHandle "print 'execute update statistics %s'\ngo\n", $tabAndCol);
	printf ($outputFileHandle "update statistics %s\ngo\n", $tabAndCol);
  }
}
close($inputFileHandle);
close($outputFileHandle);
printf ("Parsing done, check output file %s\n", $outputFilename);
