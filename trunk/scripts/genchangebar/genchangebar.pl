#! /usr/bin/perl 

use Getopt::Long;
my $revision;


GetOptions("revision|r=s" => \$revision);


my $diff2cb = $0;

$diff2cb =~ s/genchangebar\.pl$/diff2cb\.pl/;


my @svn_st = `svn st`;
my $cmd;

foreach (@svn_st) {
    if (/^(M|A|G) +(.*\.tex)$/) {
	print "$1 ";
	$cmd = sprintf("svn diff -r $revision --diff-cmd diff -x \"-U 0\" $2 > $2.cbdiff");
	print "$cmd\n";
	eval {system $cmd};
	
	$cmd = sprintf("perl $diff2cb $2");
	print "  $cmd\n";
	eval {system $cmd};
	print "\n";

    }
}

