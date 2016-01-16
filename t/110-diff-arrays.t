#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 2;

use Struct::Diff qw(diff);

my $diff;

ok($diff = diff([qw(1 2 www)], [qw(1 2 www 4)]) and
    keys %{$diff} == 2 and
    $diff->{'added'}->[0] == 4 and
    $diff->{'common'}->[0] == 1 and
    $diff->{'common'}->[1] == 2 and
    $diff->{'common'}->[2] eq 'www'
);

ok($diff = diff([qw(1 2 3)], [qw(1 1 2 3 4)]) and
    keys %{$diff} == 3 and
    $diff->{'added'}->[0] == 3 and
    $diff->{'added'}->[1] == 4 and
    $diff->{'changed'}->[0]->[0] == 2 and
    $diff->{'changed'}->[0]->[1] == 1 and
    $diff->{'changed'}->[1]->[0] == 3 and
    $diff->{'changed'}->[1]->[1] == 2 and
    $diff->{'common'}->[0] == 1
);
