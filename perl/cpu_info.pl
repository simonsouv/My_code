#!/usr/bin/perl -w

# this script gives some information about linux processor
# it displays the list of socket, cores per socket and whether the hyperthreading is enabled

use strict;

my $cpuInfo='/proc/cpuinfo';
(open my $cpuInfoHandle,'<',$cpuInfo) or die"ERROR -- File $cpuInfo, $!\n";

my $nbeCpu=0;
my %coreHash; #a two dimension array to keep track of the assoiated socketID and coreID for each logical cpu
my ($curSocket, $curCore)=(-1);

while ( defined(my $currentLine=<$cpuInfoHandle>) ){
  $nbeCpu++ if $currentLine =~ m/^processor/; #line starting with processor indicates a new logical cpu so we increase the counter
  if ( $currentLine =~ m/^physical id/ ){ #get the ID of the current socket
    $curSocket=(split(/ /,$currentLine))[-1];
    chomp($curSocket);
    #printf ("Current socket id: %s",$curSocket);
  }
  if ( $currentLine =~ m/^core id/ ){ #get the ID of the current core
    $curCore=(split(/ /,$currentLine))[-1];
    chomp($curCore);
    #printf ("Current core id: %s",$curCore);
  }
  if ($currentLine =~ m/^$/){ # an empty line is met in this case all the information related to a particular logical cpu is retrieved
    #printf ("Socket ID:%s \t Core ID:%s\n",$curSocket,$curCore);
    $coreHash{$curSocket}{$curCore}++ if exists $coreHash{$curSocket}{$curCore}; #if the couple {sockeID,coreID} is already in %coreHash then we increment,its value represents hyperthreading or not 
    $coreHash{$curSocket}{$curCore}=1 unless exists $coreHash{$curSocket}{$curCore}; #set the value to 1 for couple {sockeID,coreID} if doesn't exist
    ($curSocket, $curCore)=(-1);
  }

}

printf ("Number of logical cpu: %s\n",$nbeCpu);
printf ("No hyperthreading\n") if $coreHash{0}{0}==1;
printf ("Hyperthreading activated. Number of threads per core=%s\n",$coreHash{0}{0}) unless $coreHash{0}{0}==1;
for my $keys (keys %coreHash){
  printf ("SocketID: %s\tnumber of cores:%s\n",$keys, scalar keys %{$coreHash{$keys}}); #scalar keys %{$coreHash{$keys}} = number of keys for the second dimension of the table
}
