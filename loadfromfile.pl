#!/usr/bin/perl -w
use strict;
use Text::CSV;
use Tie::Handle::CSV;
use Getopt::Long;
use DBI;

my @tablenames   = qw/agency calendar calendar_dates routes stops trips stop_times/;

my $path_to_data = "input";
my $database 	 = "agency_gtfs";
my $fh;

GetOptions(
    "path|p=s" => \$path_to_data,
    "database|d=s" => \$database
);


open($fh, '>', qq[$path_to_data/$database/load-data.sql]) or die "Could not open file for writing SQL commands: $!";

print $fh "USE " . $database . "\;\n\n";

foreach my $table (@tablenames) {
    print "Loading $table\n";
    loadtable($table);
    print "$table loaded\n";
}

sub loadtable {
    my $table = shift;
    my $outfh = $fh;

    my $csvparser = Text::CSV->new( { binary => 1, blank_is_undef => 1, empty_is_undef => 1, allow_whitespace => 1} );
    open my $csv_fh, '<', "$path_to_data/$database/$table.txt" or die "$!";

    my @fieldslist = @{$csvparser->getline($csv_fh)};
    my $fieldstring = "(" . (join ",", @fieldslist) . ")";
    
    my $loaddataquery = qq[LOAD DATA LOCAL INFILE '$path_to_data/$database/$table.txt' REPLACE INTO TABLE $table COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\\r\\n' IGNORE 1 LINES ];

    if ($table eq "stop_times") {
        $fieldstring =~ s/arrival_time/\@avar/;
        $fieldstring =~ s/departure_time/\@dvar/;
        $loaddataquery .= $fieldstring . q[ SET arrival_time=NULLIF(@avar,''),departure_time=NULLIF(@dvar,'')];
        if ($fieldstring =~ /shape_dist_traveled/) {
            $loaddataquery =~ s[shape_dist_traveled][\@svar];
            $loaddataquery .= q[,shape_dist_traveled=NULLIF(@svar,'')];
        }
    } else {
        $loaddataquery .= $fieldstring;
    }
    close $csv_fh;

    print $outfh "TRUNCATE TABLE $table\;\n";
    print $outfh "$loaddataquery\;\n";
    print $outfh "\n";

    #$dbh->disconnect;
}
