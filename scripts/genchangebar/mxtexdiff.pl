#! /usr/bin/perl 

use Getopt::Long;
use IO::File;
use strict;

my $bar = '{\marginnote{\color{red}\rule{3pt}{2.2ex}}}';

my $new = shift;
my $diff = $new . ".cbdiff";

my $current_pos = 1;

my $new_fh = new IO::File $new;
die "Error:Cannot open $new for read.\n" if !defined $new_fh;

my $changebar_file = $new . ".changebar";
my $cb_fh = new IO::File "> $changebar_file";
die "Error:Cannot open $cb_fh for write.\n" if !defined $cb_fh;

open DIFF, "$diff" or die "Error:Cannot open $diff for read.\n";
while ( <DIFF> ) {
    if (/^\@\@.*\+(.*) \@\@$/) {
	my $range = $1;
	print "$range, ";
	if ($range =~ /^([0-9]+)(,0)?$/ ) {
	    print "addcb($1)\n";
	    &addcb($1, $1);
	}
	elsif ($range =~ /^([0-9]+)\,([0-9]+)$/) {
	    print "addcb($1, $2)\n";
	    &addcb($1, $1+$2-1);
	}
	else {
	    die "Error:What the fuck $range\n";
	}
    }
}
close DIFF;
&addcb(-1, 0);

$cb_fh->close;
$new_fh->close;



sub addcb {
    my ($start, $end) = @_;

    while ( <$new_fh> ) {
	if ( $start < 0 ) {
	    print $cb_fh $_;
	}
	else {
	    chomp;

	    if ($current_pos >= $start && $current_pos <= $end) {
		if ( /(^[ \t]+\\hline)|\\tableheader/) {
		    print $cb_fh "$_\n";
		}
		elsif (/(.*)\\\\[ \t]*$/) {
		    print $cb_fh "$1$bar\\\\\n";
		}
		elsif (/\\begin|\\end|(^[ \t]*$)/) {
		    print $cb_fh "$_\n";
		}
		else {
		    print $cb_fh "$_$bar\n";
		}
	    }
	    else {
		print $cb_fh "$_\n";
	    }

	    if ($current_pos == $end ) {
		return ++$current_pos;
	    }
	    else {
		$current_pos++;
	    }
	}
    }
    
    return 0;
    
}

