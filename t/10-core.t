#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 9;

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

$diff = diff({'key1' => 'val1', 'key2' => {'skey1' => 'sval1'}, 'key3' => 123}, {'key1' => 'val1', 'key2' => {'skey1' => 'sval2'}});
ok(keys %{$diff} == 3 and
    $diff->{'changed'}->{'key2'}->[0]->{skey1} eq 'sval1' and
    $diff->{'changed'}->{'key2'}->[1]->{skey1} eq 'sval2' and
    $diff->{'common'}->{'key1'} eq 'val1' and
    $diff->{'removed'}->{'key3'} == 123
);

my $struct1 = {
    'h1' => [
        'h1a1v1' => [ "h1a1v11", "h1a1v12", "h1a1v13" ],
        [ "h1a1a2v1", "h1a1a2v1" ],
        'h1a1v2',
        'h1a1v3',
    ],
    'h2' => {
        'h2hv1' => {},
        'h2hv2' => undef,
        'h2hv3' => 23,
        'h2hv4' => {
            'h2hv4v1' => 'h2hv4v1_test',
        },
    },
    'h3' => undef,
    'h4' => '111',
};

my $struct2 = {
    'h1' => [
        'h1a1v1' => [ "h1a1v11_", "h1a1v12", "h1a1v13" ],
        [ "h1a1a2v1", "h1a1a2v1" ],
        'h1a1v2',
        'h1a1v3',
    ],
    'h2' => {
        'h2hv1' => {},
        'h2hv2' => undef,
        'h2hv3' => 23,
        'h2hv4' => {
            'h2hv4v1' => 'h2hv4v1_test',
        },
    },
    'h3' => 'newval',
    'h5' => 'added'
};

$diff = diff($struct1, $struct2);
ok(keys %{$diff} == 4 and
    $diff->{'added'}->{'h5'} eq 'added' and
    $diff->{'changed'}->{'h1'}->[0]->[0] eq 'h1a1v1' and
    $diff->{'common'}->{'h2'}->{'h2hv4'}->{'h2hv4v1'} eq 'h2hv4v1_test' and
    $diff->{'removed'}->{'h4'} eq '111'
);
