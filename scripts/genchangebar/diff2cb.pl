#! /usr/bin/perl 

use Getopt::Long;
use IO::File;
use strict;

my $dirfile;
my $cbdiff;

GetOptions("dirfile=s"    => \$dirfile, 
	   "cbdiff=s"     => \$cbdiff);


my $bar = '{\marginnote{\color{red}\rule{3pt}{2.2ex}}}';



my $current_pos = 1;


my @diff;
if (-r $cbdiff) {
    open DIFF, "$cbdiff" or die "Error:Cannot open $cbdiff for read.\n";
    @diff = <DIFF>;
    close DIFF;
}
else {
    exit 0;
}

my $new_fh;
my $changebar_file;
my $cb_fh;

if (@diff) {
    
    $new_fh = new IO::File $dirfile;
    die "Error:Cannot open $dirfile for read.\n" if !defined $new_fh;

    $changebar_file = $cbdiff;
    $changebar_file =~ s/\.cbdiff$/.changebar/;
    $cb_fh = new IO::File "> $changebar_file";
    die "Error:Cannot open $cb_fh for write.\n" if !defined $cb_fh;

    foreach (@diff) {
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

    &addcb(-1, 0);

    $cb_fh->close;
    $new_fh->close;
}


sub addcb {
    my ($start, $end) = @_;

    while ( <$new_fh> ) {
	if ( $start < 0 ) {
	    print $cb_fh $_;
	}
	else {
	    chomp;

	    if ($current_pos >= $start && $current_pos <= $end) {
		if (($dirfile =~ /\.tex$/) || 
		    ($dirfile =~ /\.sty$/ && 
		     !/^[ \t]*(name|parent|sort|text)=\{.*\},[ \t]*$/ && 
		     !/^[ \t]*[{}][ \t]*$/                            && 
		     !/newglossaryentry/ ) ) {
		
		    if ( /(^[ \t]+\\hline)|\\tableheader|\\begin|\\end|\\input|(^[ \t]*$)/) {
			print $cb_fh "$_\n";
		    }
		    elsif (/^(.*)(\\color(wordbox|bitbox)(\[.*\])?\{.*\}\{.*\}\{)(.*)/) {
			print $cb_fh "$1$2$bar$5\n";
		    }
		    elsif (/^(.*)(\\(wordbox|bitbox)(\[.*\])?\{.*\}\{)(.*)/) {
			print $cb_fh "$1$2$bar$5\n";
		    }
		    elsif (/(.*)\\\\[ \t]*$/) {
			print $cb_fh "$1$bar\\\\\n";
		    }
		    else {
			print $cb_fh "$_$bar\n";
		    }
		}
		else {
		    print $cb_fh "$_\n";
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

