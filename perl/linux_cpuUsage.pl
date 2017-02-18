#!/usr/bin/perl

# Ref: Calculating CPU Usage from /proc/stat
# (http://colby.id.au/node/39)
# changed the code to only display two occurences
# the next purpose is to defined this script in a functions or package and collect the return value to be used later

use strict;
use warnings 'all';
use utf8;

use List::Util qw(sum);

$| = 1;

my ($prev_idle, $prev_total, $diff_usage) = qw(0 0 0 0);

#while ( $compteur<=2 ) {
foreach my $i (0..1){
        open(STAT, '/proc/stat') or die "WTF: $!";
        while (<STAT>) {
                next unless /^cpu\s+/; #The very first "cpu" line aggregates the numbers in all of the other "cpuN" lines 
                my @cpu = split /\s+/, $_;
				#print "content of array cpu: @cpu\n";
                shift @cpu;

                my $idle = $cpu[3];
                my $total = sum(@cpu);

                my $diff_idle = $idle - $prev_idle;
                my $diff_total = $total - $prev_total;
                $diff_usage = 100 * ($diff_total - $diff_idle) / $diff_total;

                $prev_idle = $idle;
                $prev_total = $total;
        }
        close STAT;
		printf "CPU: %0.2f%%  \n", $diff_usage;
        sleep 1;
}
exit $diff_usage;