#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 5;

use Struct::Diff qw(diff);

my $diff;

ok($diff = diff(undef,undef) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    not defined $diff->{'common'}
);

ok($diff = diff(1,2) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] == 1 and
    $diff->{'changed'}->[1] == 2
);

ok($diff = diff({},{}) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    keys %{$diff->{'common'}} == 0
);

ok($diff = diff([],[]) and
    keys %{$diff} == 1 and
    ref $diff->{'common'} eq 'ARRAY'
    and @{$diff->{'common'}} == 0
);

ok($diff = diff([],{}) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    ref $diff->{'changed'}->[0] eq 'ARRAY' and
    @{$diff->{'changed'}->[0]} == 0 and
    ref $diff->{'changed'}->[1] eq 'HASH' and
    keys %{$diff->{'changed'}->[1]} == 0
);
