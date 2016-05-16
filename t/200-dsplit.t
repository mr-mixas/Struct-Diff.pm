#!/usr/bin/env perl

use strict;
use warnings;
use Storable qw(freeze);
use Test::More tests => 10;

use Struct::Diff qw(diff dsplit);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_d, $s);

### primitives ###
ok($s = dsplit(diff(0, 0)) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    $s->{'a'} == 0 and $s->{'b'} == 0
);

ok($s = dsplit(diff(0, 1)) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    $s->{'a'} == 0 and $s->{'b'} == 1
);

### arrays ###
$d = diff([ 0 ], [ 0, 1 ]);
ok(($s) = dsplit($d) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    @{$s->{'a'}} == 1 and $s->{'a'}->[0] == 0 and
    @{$s->{'b'}} == 2 and $s->{'b'}->[0] == 0 and $s->{'b'}->[1] == 1
);

ok($s = dsplit(diff([ 0, 1 ], [ 0 ])) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    @{$s->{'a'}} == 2 and $s->{'a'}->[0] == 0 and $s->{'a'}->[1] == 1 and
    @{$s->{'b'}} == 1 and $s->{'b'}->[0] == 0
);

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$d = diff($a, $b, 'noU' => 0);
$frozen_d = freeze($d);

ok($s = dsplit($d) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    @{$s->{'a'}} == 5 and
        $s->{'a'}->[0] == 0 and
        @{$s->{'a'}->[1]} == 1 and @{$s->{'a'}->[1]->[0]} == 1 and @{$s->{'a'}->[1]->[0]} == 1 and $s->{'a'}->[1]->[0]->[0] == 100 and
        @{$s->{'a'}->[2]} == 2 and
            $s->{'a'}->[2]->[0] == 20 and
            $s->{'a'}->[2]->[1] eq 'a' and
        @{$s->{'a'}->[3]} == 3 and
            $s->{'a'}->[3]->[0] == 0 and
            @{$s->{'a'}->[3]->[1]} == 2 and $s->{'a'}->[3]->[1]->[0] == 11 and $s->{'a'}->[3]->[1]->[1] == 12 and
            $s->{'a'}->[3]->[2] == 2 and
        $s->{'a'}->[4] == 4 and
    @{$s->{'b'}} == 5 and
        $s->{'b'}->[0] == 0 and
        @{$s->{'b'}->[1]} == 1 and @{$s->{'b'}->[1]->[0]} == 1 and @{$s->{'b'}->[1]->[0]} == 1 and $s->{'b'}->[1]->[0]->[0] == 100 and
        @{$s->{'b'}->[2]} == 2 and
            $s->{'b'}->[2]->[0] == 20 and
            $s->{'b'}->[2]->[1] eq 'b' and
        @{$s->{'b'}->[3]} == 3 and
            $s->{'b'}->[3]->[0] == 0 and
            @{$s->{'b'}->[3]->[1]} == 2 and $s->{'b'}->[3]->[1]->[0] == 11 and $s->{'b'}->[3]->[1]->[1] == 12 and
            $s->{'b'}->[3]->[2] == 2 and
        $s->{'b'}->[4] == 5
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

$d = diff($a, $b, 'noU' => 1);
$frozen_d = freeze($d);

ok($s = dsplit($d) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    @{$s->{'a'}} == 2 and
        @{$s->{'a'}->[0]} == 1 and $s->{'a'}->[0]->[0] eq 'a' and
        $s->{'a'}->[1] == 4 and
    @{$s->{'b'}} == 2 and
        @{$s->{'b'}->[0]} == 1 and $s->{'b'}->[0]->[0] eq 'b' and
        $s->{'b'}->[1] == 5
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

### hashes ###

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b);
$frozen_d = freeze($d);

ok($s = dsplit($d) and
    keys %{$s} == 2 and exists $s->{'a'} and exists $s->{'b'} and
    keys %{$s->{'a'}} == 3 and
        exists $s->{'a'}->{'a'} and $s->{'a'}->{'a'} eq 'a1' and
        exists $s->{'a'}->{'b'} and
            keys %{$s->{'a'}->{'b'}} == 2 and
                exists $s->{'a'}->{'b'}->{'ba'} and $s->{'a'}->{'b'}->{'ba'} eq 'ba1' and
                exists $s->{'a'}->{'b'}->{'bb'} and $s->{'a'}->{'b'}->{'bb'} eq 'bb1' and
        exists $s->{'a'}->{'c'} and $s->{'a'}->{'c'} eq 'c1' and
    keys %{$s->{'b'}} == 3 and
        exists $s->{'b'}->{'a'} and $s->{'b'}->{'a'} eq 'a1' and
        exists $s->{'b'}->{'b'} and
            keys %{$s->{'b'}->{'b'}} == 2 and
                exists $s->{'b'}->{'b'}->{'ba'} and $s->{'b'}->{'b'}->{'ba'} eq 'ba2' and
                exists $s->{'b'}->{'b'}->{'bb'} and $s->{'b'}->{'b'}->{'bb'} eq 'bb1' and
        exists $s->{'b'}->{'d'} and $s->{'b'}->{'d'} eq 'd1'
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged
