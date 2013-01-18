
my $t1file;
my $eu1file;
foreach $t1file (@ARGV) {

    $eu1file = $t1file;
    $eu1file =~ s/t1/eu1/ ;

    print "$t1file  ->  $eu1file\n";
    
    open T1, "$t1file" or die "Error:cannot open $t1file for read.\n";
    open EU1, ">$eu1file" or die "Error:Cannot open $eu1file for write.\n";
    while (<T1>) {
	s/t1/eu1/g;
	s/T1/EU1/g;
	print EU1 $_;
    }

    close EU1;
    close T1;
}
