#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 2;

use Struct::Diff qw(diff);

my $diff;

$diff = diff({'key1' => 'val1', 'key2' => {'skey1' => 'sval1'}, 'key3' => 123}, {'key1' => 'val1', 'key2' => {'skey1' => 'sval2'}});
ok(keys %{$diff} == 3 and
    $diff->{'C'}->{'key2'}->[0]->{skey1} eq 'sval1' and
    $diff->{'C'}->{'key2'}->[1]->{skey1} eq 'sval2' and
    $diff->{'U'}->{'key1'} eq 'val1' and
    $diff->{'R'}->{'key3'} == 123
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
    'h5' => 'A'
};

$diff = diff($struct1, $struct2);
ok(keys %{$diff} == 4 and
    $diff->{'A'}->{'h5'} eq 'A' and
    $diff->{'C'}->{'h1'}->[0]->[0] eq 'h1a1v1' and
    $diff->{'U'}->{'h2'}->{'h2hv4'}->{'h2hv4v1'} eq 'h2hv4v1_test' and
    $diff->{'R'}->{'h4'} eq '111'
);
