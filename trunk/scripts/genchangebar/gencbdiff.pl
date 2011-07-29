#! /usr/bin/perl 

use Getopt::Long;
my $revision;
my $diffopt;

GetOptions("revision|r=s" => \$revision,
	   "diffopt=s"   => \$diffopt);

my $cmd;

foreach (@ARGV) {
    print "$_ ";
    $cmd = sprintf("svn diff -r $revision $diffopt $_ > $_.cbdiff");
    print "$cmd\n";
    eval {system $cmd};
}

