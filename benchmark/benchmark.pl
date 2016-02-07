#!/usr/bin/env perl

use strict;
use warnings;

use lib '../lib';

use Benchmark qw (:all);
use Storable qw(dclone);
use Struct::Diff qw(diff);
use Structs;

my $cloned = dclone($Structs::STRUCT1);

for my $type ('AoA', 'HoH', 'MIX') {
    my $rivals = {};
    $rivals->{"SD_${type}_det0"} = sub { diff($Structs::STRUCT1->{"${type}"}, $cloned->{"${type}"}), 'detailed' => 0 };
    $rivals->{"SD_${type}_det1"} = sub { diff($Structs::STRUCT1->{"${type}"}, $cloned->{"${type}"}), 'detailed' => 1 };
    cmpthese (100, $rivals);
}
