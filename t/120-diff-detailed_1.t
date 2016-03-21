#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone freeze);
use Test::More tests => 14;

use Struct::Diff qw(diff);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_a, $frozen_b);

### primitives ###
ok($d = diff(1, 2, 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'C'} and @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] == 1 and
    $d->{'C'}->[1] == 2
);

### arrays ###
ok($d = diff([ 0 ], [ 0, 1 ], 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'A'} and $d->{'D'}->[1]->{'A'} == 1
);

ok($d = diff([ 0, 1 ], [ 0 ], 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'R'} and $d->{'D'}->[1]->{'R'} == 1
);

ok($d = diff([ 0 ], [ 0, 1 ], 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 1 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'A'} and $d->{'D'}->[0]->{'A'} == 1
);

ok($d = diff([ 0, 1 ], [ 0 ], 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 1 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'R'} and $d->{'D'}->[0]->{'R'} == 1
);

ok($d = diff([ 0 ], [ 1 ], 'detailed' => 1, 'separate-changed' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 1 and keys %{$d->{'D'}->[0]} == 2 and
        exists $d->{'D'}->[0]->{'R'} and $d->{'D'}->[0]->{'R'} == 0 and
        exists $d->{'D'}->[0]->{'A'} and $d->{'D'}->[0]->{'A'} == 1
);

my $sub_array = [ 0, [ 11, 12 ], 2 ]; # must be considered as equal by ref (wo descending into it)
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b, 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 5 and (grep { keys %{$_} } @{$d->{'D'}}) == 5 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'U'} and @{$d->{'D'}->[1]->{'U'}} == 1 and
        @{$d->{'D'}->[1]->{'U'}->[0]} == 1 and $d->{'D'}->[1]->{'U'}->[0]->[0] == 100 and
    keys %{$d->{'D'}->[2]} == 1 and exists $d->{'D'}->[2]->{'D'} and @{$d->{'D'}->[2]->{'D'}} == 2 and
        keys %{$d->{'D'}->[2]->{'D'}->[0]} == 1 and exists $d->{'D'}->[2]->{'D'}->[0]->{'U'} and
            $d->{'D'}->[2]->{'D'}->[0]->{'U'} == 20 and
        keys %{$d->{'D'}->[2]->{'D'}->[1]} == 1 and exists $d->{'D'}->[2]->{'D'}->[1]->{'C'} and
            @{$d->{'D'}->[2]->{'D'}->[1]->{'C'}} == 2 and
            $d->{'D'}->[2]->{'D'}->[1]->{'C'}->[0] eq 'a' and
            $d->{'D'}->[2]->{'D'}->[1]->{'C'}->[1] eq 'b' and
    keys %{$d->{'D'}->[3]} == 1 and exists $d->{'D'}->[3]->{'U'} and @{$d->{'D'}->[3]->{'U'}} == 3 and
        $d->{'D'}->[3]->{'U'}->[0] == 0 and
        @{$d->{'D'}->[3]->{'U'}->[1]} == 2 and
            $d->{'D'}->[3]->{'U'}->[1]->[0] == 11 and
            $d->{'D'}->[3]->{'U'}->[1]->[1] == 12 and
        $d->{'D'}->[3]->{'U'}->[2] == 2 and
    keys %{$d->{'D'}->[4]} == 1 and exists $d->{'D'}->[4]->{'C'} and @{$d->{'D'}->[4]->{'C'}} == 2 and
        $d->{'D'}->[4]->{'C'}->[0] == 4 and
        $d->{'D'}->[4]->{'C'}->[1] == 5
);

ok($d = diff($a, $b, 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'D'} and @{$d->{'D'}->[0]->{'D'}} == 1 and
        keys %{$d->{'D'}->[0]->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'D'}->[0]->{'C'} and
            @{$d->{'D'}->[0]->{'D'}->[0]->{'C'}} == 2 and
            $d->{'D'}->[0]->{'D'}->[0]->{'C'}->[0] eq 'a' and
            $d->{'D'}->[0]->{'D'}->[0]->{'C'}->[1] eq 'b' and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'C'} and @{$d->{'D'}->[1]->{'C'}} == 2 and
        $d->{'D'}->[1]->{'C'}->[0] == 4 and
        $d->{'D'}->[1]->{'C'}->[1] == 5
);

ok($d = diff($a, $b, 'detailed' => 1, 'nocommon' => 1, 'positions' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
    keys %{$d->{'D'}->[0]} == 2 and
        exists $d->{'D'}->[0]->{'D'} and @{$d->{'D'}->[0]->{'D'}} == 1 and
            keys %{$d->{'D'}->[0]->{'D'}->[0]} == 2 and
                exists $d->{'D'}->[0]->{'D'}->[0]->{'C'} and @{$d->{'D'}->[0]->{'D'}->[0]->{'C'}} == 2 and
                    $d->{'D'}->[0]->{'D'}->[0]->{'C'}->[0] eq 'a' and
                    $d->{'D'}->[0]->{'D'}->[0]->{'C'}->[1] eq 'b' and
                exists $d->{'D'}->[0]->{'D'}->[0]->{'position'} and
                    $d->{'D'}->[0]->{'D'}->[0]->{'position'} == 1 and
        exists $d->{'D'}->[0]->{'position'} and
            $d->{'D'}->[0]->{'position'} == 2 and
    keys %{$d->{'D'}->[1]} == 2 and
        exists $d->{'D'}->[1]->{'C'} and @{$d->{'D'}->[1]->{'C'}} == 2 and
            $d->{'D'}->[1]->{'C'}->[0] == 4 and
            $d->{'D'}->[1]->{'C'}->[1] == 5 and
        exists $d->{'D'}->[1]->{'C'} and
            $d->{'D'}->[1]->{'position'} == 4
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged

### hashes ###

ok($d = diff({ 'a' => 0 }, { 'a' => 1 }, 'detailed' => 1, 'separate-changed' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and keys %{$d->{'D'}} == 1 and exists $d->{'D'}->{'a'} and
        keys %{$d->{'D'}->{'a'}} == 2 and
            exists $d->{'D'}->{'a'}->{'R'} and $d->{'D'}->{'a'}->{'R'} == 0 and
            exists $d->{'D'}->{'a'}->{'A'} and $d->{'D'}->{'a'}->{'A'} == 1
);

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b, 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and keys %{$d->{'D'}} == 4 and
    keys %{$d->{'D'}->{'a'}} == 1 and exists $d->{'D'}->{'a'}->{'U'} and $d->{'D'}->{'a'}->{'U'} eq 'a1' and
    keys %{$d->{'D'}->{'b'}} == 1 and exists $d->{'D'}->{'b'}->{'D'} and
        keys %{$d->{'D'}->{'b'}->{'D'}} == 2 and
        exists $d->{'D'}->{'b'}->{'D'}->{'ba'} and keys %{$d->{'D'}->{'b'}->{'D'}->{'ba'}} == 1 and
            exists $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'} and
            @{$d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'}} == 2 and
            $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'}->[0] eq 'ba1' and
            $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'}->[1] eq 'ba2' and
        exists $d->{'D'}->{'b'}->{'D'}->{'bb'} and keys %{$d->{'D'}->{'b'}->{'D'}->{'bb'}} == 1 and
            exists $d->{'D'}->{'b'}->{'D'}->{'bb'}->{'U'} and
            $d->{'D'}->{'b'}->{'D'}->{'bb'}->{'U'} eq 'bb1' and
    keys %{$d->{'D'}->{'c'}} == 1 and exists $d->{'D'}->{'c'}->{'R'} and $d->{'D'}->{'c'}->{'R'} eq 'c1' and
    keys %{$d->{'D'}->{'d'}} == 1 and exists $d->{'D'}->{'d'}->{'A'} and $d->{'D'}->{'d'}->{'A'} eq 'd1'
);

ok($d = diff($a, $b, 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and keys %{$d->{'D'}} == 3 and
    keys %{$d->{'D'}->{'b'}} == 1 and exists $d->{'D'}->{'b'}->{'D'} and
        keys %{$d->{'D'}->{'b'}->{'D'}} == 1 and
        exists $d->{'D'}->{'b'}->{'D'}->{'ba'} and keys %{$d->{'D'}->{'b'}->{'D'}->{'ba'}} == 1 and
            exists $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'} and
            @{$d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'}} == 2 and
            $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'}->[0] eq 'ba1' and
            $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'C'}->[1] eq 'ba2' and
    keys %{$d->{'D'}->{'c'}} == 1 and exists $d->{'D'}->{'c'}->{'R'} and $d->{'D'}->{'c'}->{'R'} eq 'c1' and
    keys %{$d->{'D'}->{'d'}} == 1 and exists $d->{'D'}->{'d'}->{'A'} and $d->{'D'}->{'d'}->{'A'} eq 'd1'
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged
