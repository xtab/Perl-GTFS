#!/usr/bin/perl -w
use strict;
#############################################################################
#  Pattern - implement GTFS minimum functionality for patterns
#
#  Object Attributes:
#  pattern_id - calculated (int)
#  STOPS - array of stop_ids in order
#  INDEXES - array of stop_sequences in order
#  ROUTE - route id associated with this pattern
#  TRIP - example trip id associated with this pattern
#
#  Methods:
#  new - create a new Pattern object, with blank data
#  pattern_id - get or set pattern_id attribute
#  stops - get or set STOP array 
#  indexes - get or set INDEXES array 
#  stop_sequence - get or set STOP sequence
#  route - get or set ROUTE
#  isequal - test whether the pattern is equal to another pattern
#  

package Pattern;
use Digest::MurmurHash qw(murmur_hash);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(@_patterns_reqcols @_patterns_optcols);

our @_patterns_reqcols = qw/route_id pattern_id stop_sequence stop_id distance/;
our @_patterns_optcols = qw//;

sub new {
	my $proto = shift;
    my $data = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	$self->{pattern_id} = $data->{pattern_id} or die "No pattern_id sent to New: $!";
	$self->{COUNT} = $data->{COUNT} if $data->{COUNT};
	$self->{route_id} = $data->{route_id} if $data->{route_id};
	$self->{TOTALDIST} = $data->{TOTALDIST} || $data->{DISTANCES}[-1] || undef;
	$self->{STOPS} = $data->{STOPS} || [];
	$self->{INDEXES} = $data->{INDEXES} || [];
	$self->{DISTANCES} = $data->{DISTANCES} || [];
	return bless($self, $class);
}

sub pattern_id {
	my $self = shift;
	if (@_) { $self->{pattern_id} = shift }
	return $self->{pattern_id};
}

sub trip {
	my $self = shift;
	if (@_) { $self->{TRIP} = shift }
	return $self->{TRIP};
}

sub count {
	my $self = shift;
	if (@_) { $self->{COUNT} = shift }
	return $self->{COUNT};
}

sub route_id {
	my $self = shift;
	if (@_) { $self->{route_id} = shift }
	return $self->{route_id};
}

sub totaldist {
	my $self = shift;
	if (@_) { $self->{TOTALDIST} = shift }
	return $self->{TOTALDIST};
}

sub stops { 
	my $self = shift;
	if ($_ = shift) { $self->{STOPS} = $_; }
	return $self->{STOPS}; 
}

sub addstop { 
	my $self = shift;
    my $newstop = shift;
    push @{ $self->{STOPS} }, $newstop;
	return $self->{STOPS}; 
}

sub indexes { 
	my $self = shift;
	if ($_ = shift) { $self->{INDEXES} = $_; }
	return $self->{INDEXES}; 
}

sub addindex { 
	my $self = shift;
    my $newindex = shift;
    push @{ $self->{INDEXES} }, $newindex;
	return $self->{INDEXES}; 
}

sub distances { 
	my $self = shift;
	if ($_ = shift) { $self->{DISTANCES} = $_; }
	return $self->{DISTANCES}; 
}

sub adddistance { 
	my $self = shift;
    my $newdist = shift;
    push @{ $self->{DISTANCES} }, $newdist;
	return $self->{DISTANCES}; 
}

sub isequal {
    my $self = shift;
    my $other = shift;
    my $astops = join ",", @{ $self->{STOPS}  };
    my $bstops = join ",", @{ $other->{STOPS} };
    my $ahash = $self->{hash} || ($self->{hash} = murmur_hash($astops));
    my $bhash = $other->{hash} || ($other->{hash} = murmur_hash($bstops));

    return 0 if ($ahash != $bhash);
    return 1; 

    #if ($#astops != $#bstops) {return 0;} # not equal length arrays can't be equal!
    #my $length = $#astops;
    #for (my $i = 0; $i < $length; $i++)  {
    #    return 0 if ($astops[$i] != $bstops[$i]);
    #}
    #return 1;
}

sub fromDB {
    my $class = shift;
    my $dbh = shift;

    my %patterns;

    my $PATTERNQUERY1 = "SELECT DISTINCT route_id, pattern_id from patterns";
    my $sth1 = $dbh->prepare($PATTERNQUERY1);
    $sth1->execute;

    my $PATTERNQUERY2 = "SELECT stop_sequence, stop_id, distance from patterns where pattern_id = ?";
    my $sth2 = $dbh->prepare($PATTERNQUERY2);

    while (my ($route_id, $pattern_id) = $sth1->fetchrow()) {

        my @stop_ids = ();
        my @stop_indexes = ();
        my @distances = ();

        $sth2->execute($pattern_id);
        while (my ($stop_sequence, $stop_id, $distance) = $sth2->fetchrow()) {
            push @stop_indexes, $stop_sequence;
            push @stop_ids, $stop_id;
            push @distances, $distance;
        }

        $patterns{$pattern_id} = $class->new( { 
                pattern_id => $pattern_id,
                ROUTE => $route_id,
                STOPS => \@stop_ids,
                INDEXES => \@stop_indexes,
                DISTANCES => \@distances,
            });
        print "Loaded pattern: $pattern_id\n";
    }

    return \%patterns;
}
    
1;
