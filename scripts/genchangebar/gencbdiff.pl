#! /usr/bin/perl 

use Getopt::Long;
my $revision;
my $diffopt;
my $builddir;
my $file;

GetOptions("revision|r=s" => \$revision,
	   "diffopt=s"    => \$diffopt,
	   "builddir=s"   => \$builddir,
	   "file=s"       => \$file);

my $cmd = sprintf("svn diff -r $revision $diffopt $file > $builddir/$file.cbdiff");

print "$file $cmd\n";
system $cmd;

