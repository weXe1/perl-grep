#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

our(
    $opt_p, # pattern
    $opt_f, # file
    $opt_i, # ignore case
    $opt_x, # exclude matches
    $opt_b, # begins with match
    $opt_e, # ends with match
    $opt_h  # help
);

my (@data, @output);

sub matches {
    my $pattern = shift;
    my $string = shift;
    my $i = shift;

    if ($i) {
        return ($string =~ /$pattern/i) ? 1 : 0;
    } else {
        return ($string =~ /$pattern/) ? 1 : 0;
    }
}

sub usage {
    my $usage = "usage:\n";
    $usage .= "\$ perl $0 -p <pattern> [-i] [-f <filename>] [-x|-b|-e]\n";
    $usage .= "\noptions:\n\n";
    $usage .= "  -p <pattern>\tregex pattern to search for\n";
    $usage .= "  -i\t\tignore case\n";
    $usage .= "  -f <filename>\tfile to search pattern in\n";
    $usage .= "  -x\t\texclude matched lines\n";
    $usage .= "  -b\t\tprint everything below the first matched line\n";
    $usage .= "  -e\t\tprint everything above the first matched line\n";
    $usage .= "  -h\t\tprint this help and exit\n";
    $usage .= "\nexamples:\n\n";
    $usage .= "\$ ifconfig | $0 -p '(([a-z0-9]{2}):?){6}'\n";
    $usage .= "\$ ifconfig | $0 -p Wlan -i -b\n";
    $usage .= "\$ $0 -p '\\d' -f file.txt\n";
    return $usage;
}

getopts('p:f:ixbeh');

die &usage() unless $opt_p;
die &usage() if $opt_h;

my $pattern = $opt_p;

if ($opt_f) {
    open(my $fh, $opt_f) or die "Cannot open file '$opt_f': $!\n";
    while (<$fh>) {
        push @data, $_;
    }
    close $fh;
} else {
    while (<STDIN>) {
        push @data, $_;
    }
}

if ($opt_x) {
    foreach my $s (@data) {
        unless (&matches($pattern, $s, $opt_i)) {
            push @output, $s;
        }
    }
} elsif ($opt_b) {
    for (my $i = 0; $i <= $#data; ++$i) {
        if (&matches($pattern, $data[$i], $opt_i)) {
            push @output, @data[$i..$#data];
            last;
        }
    }
} elsif ($opt_e) {
    for (my $i = 0; $i <= $#data; ++$i) {
        push @output, $data[$i];
        if (&matches($pattern, $data[$i], $opt_i)) {
            last;
        }
    }
} else {
    foreach my $s (@data) {
        if (&matches($pattern, $s, $opt_i)) {
            push @output, $s;
        }
    }
}

print join('', @output);