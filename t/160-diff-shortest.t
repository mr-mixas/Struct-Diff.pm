#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 6;

use Struct::Diff qw(diff);

my $diff;

### primitives
ok($diff = diff(undef, undef, 'shortest' => 1) and
    keys %{$diff} == 0
);

ok($diff = diff(undef, 0, 'shortest' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    not defined $diff->{'changed'}->[0] and
    $diff->{'changed'}->[1] == 0
);

### arrays ###
my $s_array_1 = [ 0, 1, undef, 3, 'a', 5];
my $s_array_2 = [ 0, 1, undef, 3, 'b', 5];

ok($diff = diff($s_array_1, $s_array_1, 'shortest' => 1) and
    keys %{$diff} == 0
);

ok($diff = diff($s_array_1, $s_array_2, 'shortest' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}->[0]} == 3 and
    $diff->{'changed'}->[0]->[0] eq 'a' and
    $diff->{'changed'}->[0]->[1] eq 'b' and
    $diff->{'changed'}->[0]->[2] == 4
);

### hashes ###
my $s_hash_1 = { 'a' => 1, 'b' => undef, 'c' => 'd' };
my $s_hash_2 = { 'a' => 1, 'b' => undef, 'c' => 'e' };

ok($diff = diff($s_hash_1, $s_hash_1, 'shortest' => 1) and
    keys %{$diff} == 0
);

ok($diff = diff($s_hash_1, $s_hash_2, 'shortest' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    keys $diff->{'changed'} == 1 and
    @{$diff->{'changed'}->{'c'}} == 2 and
    $diff->{'changed'}->{'c'}->[0] eq 'd' and
    $diff->{'changed'}->{'c'}->[1] eq 'e'
);
