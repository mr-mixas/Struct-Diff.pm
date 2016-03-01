#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone);
use Test::More tests => 2;

use Struct::Diff qw(diff);

my $diff;

### arrays ###
my $s_array_1 = [ 0, 1, 2, { '3k0' => '3k0v0', '3k1' => {} }, 4, 5 ];
my $s_array_2 = [ 0, 1, 2, { '3k0' => '3k0v0', '3k1' => [] }, 4, 6 ];
ok($diff = diff($s_array_1, $s_array_2, 'separate-changed' => 1) and
    keys %{$diff} == 3 and
    exists $diff->{'A'}   and @{$diff->{'A'}}   == 2 and
    exists $diff->{'U'}  and @{$diff->{'U'}}  == 4 and
    exists $diff->{'R'} and @{$diff->{'R'}} == 2
);

### hashes ###
my $s_hash_1 = { 'k0' => [ 0, 1, 2 ], 'k1' => { 'k1v0k0' => { 'k1v0k0v0k0' => 'k1v0k0v0k0v0' } }, 'k2' => undef, 'k3' => 0 };
my $s_hash_2 = { 'k0' => [ 0, 1, 3 ], 'k1' => { 'k1v0k0' => { 'k1v0k0v0k1' => 'k1v0k0v0k0v0' } }, 'k2' => undef, 'k4' => 1 };
ok($diff = diff($s_hash_1, $s_hash_2, 'separate-changed' => 1) and
    keys %{$diff} == 3 and
    exists $diff->{'A'}   and keys %{$diff->{'A'}}   == 3 and
    exists $diff->{'U'}  and keys %{$diff->{'U'}}  == 1 and
    exists $diff->{'R'} and keys %{$diff->{'R'}} == 3
);
