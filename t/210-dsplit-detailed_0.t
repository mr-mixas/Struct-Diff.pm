#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(freeze);
use Test::More tests => 10;

use Struct::Diff qw(diff dsplit);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_a, $frozen_b, $frozen_d, $sa, $sb);

### primitives ###
ok(($sa, $sb) = dsplit(diff(0, 0, 'detailed' => 0)) and
    $sa == 0 and $sb == 0
);

ok(($sa, $sb) = dsplit(diff(0, 1, 'detailed' => 0)) and
    $sa == 0 and $sb == 1
);

### arrays ###
ok(($sa, $sb) = dsplit(diff([ 0 ], [ 0, 1 ], 'detailed' => 0)) and
    @{$sa} == 1 and $sa->[0] == 0 and
    @{$sb} == 2 and $sb->[0] == 0 and $sb->[1] == 1
);

ok(($sa, $sb) = dsplit(diff([ 0, 1 ], [ 0 ], 'detailed' => 0)) and
    @{$sa} == 2 and $sa->[0] == 0 and $sa->[1] == 1 and
    @{$sb} == 1 and $sb->[0] == 0
);

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$d = diff($a, $b, 'detailed' => 0, 'positions' => 0);
$frozen_d = freeze($d);

ok(($sa, $sb) = dsplit($d) and
    @{$sa} == 5 and
        $sa->[0] == 0 and
        @{$sa->[1]} == 1 and @{$sa->[1]->[0]} == 1 and @{$sa->[1]->[0]} == 1 and $sa->[1]->[0]->[0] == 100 and
        @{$sa->[2]} == 3 and
            $sa->[2]->[0] == 0 and
            @{$sa->[2]->[1]} == 2 and $sa->[2]->[1]->[0] == 11 and $sa->[2]->[1]->[1] == 12 and
            $sa->[2]->[2] == 2 and
        @{$sa->[3]} == 2 and
            $sa->[3]->[0] == 20 and
            $sa->[3]->[1] eq 'a' and
        $sa->[4] == 4 and
    @{$sb} == 5 and
        $sb->[0] == 0 and
        @{$sb->[1]} == 1 and @{$sb->[1]->[0]} == 1 and @{$sb->[1]->[0]} == 1 and $sb->[1]->[0]->[0] == 100 and
        @{$sb->[2]} == 3 and
            $sb->[2]->[0] == 0 and
            @{$sb->[2]->[1]} == 2 and $sb->[2]->[1]->[0] == 11 and $sb->[2]->[1]->[1] == 12 and
            $sb->[2]->[2] == 2 and
        @{$sb->[3]} == 2 and
            $sb->[3]->[0] == 20 and
            $sb->[3]->[1] eq 'b' and
        $sb->[4] == 5
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

$d = diff($a, $b, 'detailed' => 0, 'positions' => 1);
$frozen_d = freeze($d);

ok(($sa, $sb) = dsplit($d) and
    @{$sa} == 5 and
        $sa->[0] == 0 and
        @{$sa->[1]} == 1 and @{$sa->[1]->[0]} == 1 and @{$sa->[1]->[0]} == 1 and $sa->[1]->[0]->[0] == 100 and
        @{$sa->[2]} == 2 and
            $sa->[2]->[0] == 20 and
            $sa->[2]->[1] eq 'a' and
        @{$sa->[3]} == 3 and
            $sa->[3]->[0] == 0 and
            @{$sa->[3]->[1]} == 2 and $sa->[3]->[1]->[0] == 11 and $sa->[3]->[1]->[1] == 12 and
            $sa->[3]->[2] == 2 and
        $sa->[4] == 4 and
    @{$sb} == 5 and
        $sb->[0] == 0 and
        @{$sb->[1]} == 1 and @{$sb->[1]->[0]} == 1 and @{$sb->[1]->[0]} == 1 and $sb->[1]->[0]->[0] == 100 and
        @{$sb->[2]} == 2 and
            $sb->[2]->[0] == 20 and
            $sb->[2]->[1] eq 'b' and
        @{$sb->[3]} == 3 and
            $sb->[3]->[0] == 0 and
            @{$sb->[3]->[1]} == 2 and $sb->[3]->[1]->[0] == 11 and $sb->[3]->[1]->[1] == 12 and
            $sb->[3]->[2] == 2 and
        $sb->[4] == 5
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

### hashes ###

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b, 'detailed' => 0);
$frozen_d = freeze($d);

ok(($sa, $sb) = dsplit($d) and
    keys %{$sa} == 3 and
        exists $sa->{'a'} and $sa->{'a'} eq 'a1' and
        exists $sa->{'b'} and
            keys %{$sa->{'b'}} == 2 and
                exists $sa->{'b'}->{'ba'} and $sa->{'b'}->{'ba'} eq 'ba1' and
                exists $sa->{'b'}->{'bb'} and $sa->{'b'}->{'bb'} eq 'bb1' and
        exists $sa->{'c'} and $sa->{'c'} eq 'c1' and
    keys %{$sb} == 3 and
        exists $sb->{'a'} and $sb->{'a'} eq 'a1' and
        exists $sb->{'b'} and
            keys %{$sb->{'b'}} == 2 and
                exists $sb->{'b'}->{'ba'} and $sb->{'b'}->{'ba'} eq 'ba2' and
                exists $sb->{'b'}->{'bb'} and $sb->{'b'}->{'bb'} eq 'bb1' and
        exists $sb->{'d'} and $sb->{'d'} eq 'd1'
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged
