#!/usr/bin/perl -w
use strict;

while (<>) {
    # Remove line terminator
    chomp;

    # Remove UTF-8 BOM on first line
    $. == 1 and s/\xEF\xBB\xBF//;

    # Remove whitespace surrounding delimiters
    s/\s*,\s*/,/g;

    # Remove any kind of line endings (substituting it with \r\n)
    s/\r\n|\n|\r//g;

    # Ignore empty records
    next if /^\s*$/;

    print "$_\r\n";
}
