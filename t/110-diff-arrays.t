#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 2;

use Struct::Diff qw(diff);

my $diff;

ok($diff = diff([qw(1 2 www)], [qw(1 2 www 4)]) and
    keys %{$diff} == 2 and
    $diff->{'A'}->[0] == 4 and
    $diff->{'U'}->[0] == 1 and
    $diff->{'U'}->[1] == 2 and
    $diff->{'U'}->[2] eq 'www'
);

ok($diff = diff([qw(1 2 3)], [qw(1 1 2 3 4)]) and
    keys %{$diff} == 3 and
    $diff->{'A'}->[0] == 3 and
    $diff->{'A'}->[1] == 4 and
    $diff->{'C'}->[0]->[0] == 2 and
    $diff->{'C'}->[0]->[1] == 1 and
    $diff->{'C'}->[1]->[0] == 3 and
    $diff->{'C'}->[1]->[1] == 2 and
    $diff->{'U'}->[0] == 1
);
