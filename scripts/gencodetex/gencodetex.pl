#! /usr/bin/perl -w

use strict;
use Getopt::Long;

my $language;
my $topheading_t = "chapter";
my $dir_file;
my $output_file;
my $standalone;
my $showfilename;
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

if ( ! defined $dir_file ) {
    exit 0;
}

if ( ! defined $output_file ) {
    $output_file = $dir_file . ".tex";
}

my %language_ext = (
    'pl'   => 'perl', 
    'mk'   => 'makefile',
    'mhdl' => 'metahdl', 
    'v'    => 'metahdl', 
    'vp'   => 'metahdl',
    'sv'   => 'metahdl', 
    'vh'   => 'metahdl', 
    'tcl'  => 'tcl'
    );

my %language_cmt = (
    'pl'   => '# *-', 
    'mk'   => '# *-', 
    'mhdl' => '// *-',
    'v'    => '// *-',
    'vp'   => '// *-',
    'sv'   => '// *-',
    'vh'   => '// *-',
    'tcl'  => '# *-'
    );

my $extension;
if ( ! defined $language ) {
    if ( $dir_file =~ /.*\.([a-z]+)$/i ) {
        $extension = $1;
    }
    else {
        $extension = "mhdl";
    }

    $language = $language_ext{$extension};
}

my $commentstart;
$commentstart = $language_cmt{$extension};


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






my $filename = $dir_file;
$filename =~ s/^.*\/([\w.]+)$/$1/;
$filename =~ s/_/\\_/g;


open SRC, "$dir_file" or die "Error:Cannot open $dir_file for read.\n";
my $lineno=1;
my ($src_start, $src_end) = (0, 0);
my $state = "doc";

my @tex_src;

while ( <SRC> ) {
    if ($state eq "doc" ) {
	if ( /^[ \t]*$commentstart(.*)/ ) {
	    push @tex_src, &extractdoc($1);
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
	    push @tex_src, "\\begin{lstlisting}[frame=none, language={$language}, firstnumber=$src_start, nolol]\n";
	    push @tex_src, $_;
	}
    }
    else {
	if ( /^[ \t]*$commentstart(.*)/ ) {
	    push @tex_src, "\\end{lstlisting}\n\n";
# 	    $src_end = $lineno -1;
# 	    push @tex_src, "\\lstinputlisting[frame=none, language={$language}, firstnumber=$src_start, linerange={$src_start-$src_end}, nolol]{$dir_file}\n";
	    push @tex_src, &extractdoc($1);
	    $src_start = 0;
	    $src_end = 0;
	    $state = "doc";
	}
	else {
	    push @tex_src, $_;
	}
    }

    $lineno++;
}

if ( $src_start ) {
    # push @tex_src, "\\lstinputlisting[frame=none, language={$language}, firstnumber=$src_start, linerange={$src_start-$lineno}, nolol]{$dir_file}\n";
    push @tex_src, "\\end{lstlisting}\n\n";
}

close SRC;

unshift @tex_src, "$heading[$topheading]\{$filename\}\n" if !$standalone;

open TEX, ">$output_file" or die "Error:Cannot open $output_file for write.\n";
print TEX @tex_src;
close TEX;


sub extractdoc {
    my ($raw) = @_;

    my $doc = "";
    
    my $horizontal_line = '(=|-|\*){5,}';
    if ($raw =~ /gencodetex_override:(\w+)=(.*)/) {
        if ($1 eq 'topheading') {
            $topheading = $2;
        }
        elsif ($1 eq 'standalone') {
            $standalone = $2;
        }
        else {
            die("Error:Unknown variable name '$1' for gencodetex behavior override.\n");
        }
        $doc = "% $1=$2\n";
        return $doc;
    }
    elsif ( $raw =~ /$horizontal_line/ ) {
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
