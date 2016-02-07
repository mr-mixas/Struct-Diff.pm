#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

# recursive struct maker
sub smk($$;$);
sub smk($$;$) {
    my $depth = shift || return (rand(1) > 0.5) ? rand(65535) : int(rand(65535));
    my $width = shift;
    my $style = shift;

    my $out;
    if ((defined $style and ref $style eq 'ARRAY') or (not defined $style and rand(1) > 0.5)) {
        map { push @{$out}, smk($depth - 1, $width, $style) } 0..($width - 1);
    } else {
        map { $out->{$_} = smk($depth - 1, $width, $style) }
            map { (rand(1) > 0.5) ? rand(65535) : int(rand(65535)) } 0..($width - 1);
    }
    return $out;
}

srand(time + $$);

my $result;

$result->{'AoA'} = smk(6, 5, []);
$result->{'HoH'} = smk(6, 5, {});
$result->{'MIX'} = smk(6, 5);

$Data::Dumper::Indent = 0;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Varname = "STRUCT";

print "package Structs;\n";
print "our ", Dumper($result), "\n";
print "1;\n"
