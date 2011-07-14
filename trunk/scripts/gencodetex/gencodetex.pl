#! /usr/bin/perl -w

use strict;
use Getopt::Long;

my $language;
my $topheading_t = "chapter";
my $dir_file;
my $output_file;
my $standalone;
my @heading = (
    '\part',
    '\chapter',
    '\section',
    '\subsection',
    '\subsubsection',
    '\paragraph',
    '\subparagraph'
    );

GetOptions("-language=s"   => \$language,
	   "-topheading=s" => \$topheading_t,
	   "-output=s"     => \$output_file,
	   "-file=s"       => \$dir_file, 
	   "-standalone"   => \$standalone);

if ( ! defined $output_file ) {
    $output_file = $dir_file . ".tex";
}

if ( ! defined $dir_file ) {
    exit 0;
}

if ( ! defined $language ) {
    $language = "metahdl";
}

my $topheading;
for (my $i=0; $i <= $#heading; $i++) {
    if ( $heading[$i] =~ /$topheading_t/i ) {
	$topheading = $i;
	last;
    }
}

if ($standalone) { 
    $topheading--;
}



my $commentstart;

if ( $language =~ /perl|makefile/i ) {
    $commentstart = '# *-';
}
else {
    $commentstart = '// *-';
}



my $filename = $dir_file;
$filename =~ s/^.*\/([\w.]+)$/$1/;
$filename =~ s/_/\\_/g;


open SRC, "$dir_file" or die "Error:Cannot open $dir_file for read.\n";
open TEX, ">$output_file" or die "Error:Cannot open $output_file for write.\n";

my $lineno=1;
my ($src_start, $src_end) = (0, 0);
my $state = "doc";

print TEX "$heading[$topheading]\{$filename\}\n" if !$standalone;

while ( <SRC> ) {
    if ($state eq "doc" ) {
	if ( /^[ \t]*$commentstart(.*)/ ) {
	    print TEX &extractdoc($1);
	}
	elsif ( /^\#!/ ) {
	    # jumps over execution directive
	}
# 	elsif ( /^[ \t]*$/ ) {
# 	    # eat up blank line
# 	}
	else {
	    $state = "src";
	    $src_start = $lineno;
	}
    }
    else {
	if ( /^[ \t]*$commentstart(.*)/ ) {
	    $src_end = $lineno -1;
	    print TEX "\\lstinputlisting[frame=none, language={$language}, firstnumber=$src_start, linerange={$src_start-$src_end}, nolol]{$dir_file}\n";
	    print TEX &extractdoc($1);
	    $src_start = 0;
	    $src_end = 0;
	    $state = "doc";
	}
    }

    $lineno++;
}

if ( $src_start ) {
    print TEX "\\lstinputlisting[frame=none, language={$language}, firstnumber=$src_start, linerange={$src_start-$lineno}, nolol]{$dir_file}\n";
}

close SRC;
close TEX;


sub extractdoc {
    my ($raw) = @_;

    my $doc = "";
    
    my $horizontal_line = '(=|-|\*){5,}';
    if ( $raw =~ /$horizontal_line/ ) {
	return $doc;
    }
    else {
	if ( $raw =~ /^ *(\*+) *(.*)/) {
	    my $stars = $1;
	    my $text  = $2;

	    $doc = $heading[$topheading + length($1)] . 
		"{" . $text . "}\n";
	}
	else {
	    $doc = $raw . "\n";
	}
    }

    return $doc;

}
