#!/usr/bin/perl -w

# this script parses "Adapt tables" .trc file to retrieve SQL duration and save the timing per connection
# because the step is now using 2 connections to // the step

use strict;

my $connFound = 0;		#flag to indicate whether we found a connection
my $currentConn; 		#variable holding the current connection ID
my $currentLineNum=-1;		#variable that will store the line number of the SQL exectured
my %sqlDuration = (); 	# two dimension arrays that will hold SQL duration for both connections

#my $inputFile='mxmaint#adapttables_20170413-184847585_1019585362#rdb.62500_sample.trc';
my $inputFile;
my $tmpFileConn1='/tmp/conn1.tmp';
my $tmpFileConn2='/tmp/conn2.tmp';
my $resFileConn1='/tmp/conn1_results.txt';
my $resFileConn2='/tmp/conn2_results.txt';

if (! @ARGV){
  print "Missing filename. Exit\n";
  exit -1;
}
else{
  $inputFile = $ARGV[0]
}

(open my $inputFileHandle,'<',$inputFile) or die"ERROR -- File $inputFile, $!\n";
(open my $tmpFileHandleConn1,'>',$tmpFileConn1) or die"ERROR -- File $tmpFileConn1, $!\n";
(open my $tmpFileHandleConn2,'>',$tmpFileConn2) or die"ERROR -- File $tmpFileConn2, $!\n";

printf "Analysis in progress...\n";
# the while loop will parse the input file and write in two files the SQL and execution time per connectionID
while ( defined(my $currentLine=<$inputFileHandle>) ){
  if ( $currentLine =~ m/^ServerName/){	#we reach a line identifying a new connection, the next line is to be stored
    $connFound = 1;
    #printf("Current line is: %s\n", $currentLine);
    my @currentLineSplitted = split /\s+/, $currentLine;
	$currentConn = $currentLineSplitted[-4];
	#printf ("Current connection ID is: %s\n", $currentConn);
  }
  else{
    if ( $connFound ){ #we read a line immediately after identifying a connection, this line must be save in a temp file
	  #the target file is chosen based on the connection ID found in line starting with "ServerName"
	  if ( $currentConn == 1){ 
	    print $tmpFileHandleConn1 $currentLine;
	  }
	  else {
	    print $tmpFileHandleConn2 $currentLine;
	  }
	  $connFound = 0;
	}
  }
}
close($inputFileHandle);
close($tmpFileHandleConn1);
close($tmpFileHandleConn2);

printf "Parsing temporary file %s to retrieve SQL duration\n",$tmpFileConn1;
#process the first tmp file
(open $tmpFileHandleConn1,'<',$tmpFileConn1) or die"ERROR -- File $tmpFileConn1, $!\n";
while ( defined(my $currentLine=<$tmpFileHandleConn1>) ){
  if ( $currentLine !~ m/^Murex execution time/ ){ #current line is not matching a line with timing, we keep the line number
    $currentLineNum = $.;
  }
  else{ #we found a line with timing, we compute the time in ms and store it in an hash table
    my @currentLineSplitted = split /\s+/, $currentLine;
	my $time_ms = $currentLineSplitted[-2];
	my ($time_h, $time_m, $time_s) = split /:/,$currentLineSplitted[-3];
	my $total_time = ($time_h * 3600 * 1000) + ($time_m * 60 * 1000) + ($time_s * 1000) + $time_ms;
	#printf "H:%s \tM:%s\tS:%s\tMS:%s\tTOTAL:%.3f\n",$time_h, $time_m, $time_s,$time_ms,$total_time/1000.0;
	$sqlDuration{$currentLineNum} = $total_time
  }
}
close($tmpFileHandleConn1);
(open my $resFileHandleConn1,'>',$resFileConn1) or die"ERROR -- File $resFileConn1, $!\n";
print $resFileHandleConn1 "LINE #\tELAPSE(s)\n";
print $resFileHandleConn1 "------\t----------\n";
#display the content of the hash order by duration.
#to do so we use the sort method by sorting first values as number then key as number
#  more details here: https://perlmaven.com/how-to-sort-a-hash-in-perl
#  and here: https://perlmaven.com/sorting-arrays-in-perl
for my $l ( sort { $sqlDuration{$a} <=> $sqlDuration{$b} or $a <=> $b } keys %sqlDuration){
  printf $resFileHandleConn1 "%s\t%.3f\n",$l,$sqlDuration{$l}/1000.0;
}
close($resFileHandleConn1);

#process the second tmp file
$currentLineNum=-1;
%sqlDuration = ();
printf "Parsing temporary file %s to retrieve SQL duration\n",$tmpFileConn2;
(open $tmpFileHandleConn2,'<',$tmpFileConn2) or die"ERROR -- File $tmpFileConn2, $!\n";
while ( defined(my $currentLine=<$tmpFileHandleConn2>) ){
  if ( $currentLine !~ m/^Murex execution time/ ){ #current line is not matching a line with timing, we keep the line number
    $currentLineNum = $.;
  }
  else{ #we found a line with timing, we compute the time in ms and store it in an hash table
    my @currentLineSplitted = split /\s+/, $currentLine;
	my $time_ms = $currentLineSplitted[-2];
	my ($time_h, $time_m, $time_s) = split /:/,$currentLineSplitted[-3];
	my $total_time = ($time_h * 3600 * 1000) + ($time_m * 60 * 1000) + ($time_s * 1000) + $time_ms;
	#printf "H:%s \tM:%s\tS:%s\tMS:%s\tTOTAL:%.3f\n",$time_h, $time_m, $time_s,$time_ms,$total_time/1000.0;
	$sqlDuration{$currentLineNum} = $total_time
  }
}
close($tmpFileHandleConn2);
(open my $resFileHandleConn2,'>',$resFileConn2) or die"ERROR -- File $resFileConn2, $!\n";
print $resFileHandleConn2 "LINE #\tELAPSE(s)\n";
print $resFileHandleConn2 "------\t----------\n";
for my $l ( sort { $sqlDuration{$a} <=> $sqlDuration{$b} or $a <=> $b } keys %sqlDuration){
  printf $resFileHandleConn2 "%s\t%.3f\n",$l,$sqlDuration{$l}/1000.0;
}
close($resFileHandleConn2);

printf "Analysis finished.\nOutput files are %s and %s\n",$resFileConn1,$resFileConn2;
