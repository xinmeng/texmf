#! /usr/bin/perl 

use strict;
use Getopt::Long;

my $revision = "HEAD";

GetOptions("revision|r=s" => \$revision);

my $svn_info = `svn info -r $revision`;

my ($curr_rev, $last_changed_rev, $last_changed_date);

if ($svn_info =~ /Revision: ([0-9]+)/) {
    $curr_rev = $1;
}

if ($svn_info =~ /Last Changed Rev: ([0-9]+)/) {
    $last_changed_rev = $1;
}

if ($svn_info =~ /Last Changed Date: (.*) \(.*\)/) {
    $last_changed_date = $1;
}

print "Change Bar based on r$curr_rev, Last Changed on r$last_changed_rev at $last_changed_date";

