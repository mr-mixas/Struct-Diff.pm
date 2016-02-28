#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone freeze);
use Test::More tests => 16;

use Struct::Diff qw(diff);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_a, $frozen_b);

### primitives ###
ok($d = diff(1, 2, 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'changed'} and @{$d->{'changed'}} == 2 and
    $d->{'changed'}->[0] == 1 and
    $d->{'changed'}->[1] == 2
);

### arrays ###
ok($d = diff([ 0 ], [ 0, 1 ], 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 2 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'common'} and $d->{'diff'}->[0]->{'common'} == 0 and
    keys %{$d->{'diff'}->[1]} == 1 and exists $d->{'diff'}->[1]->{'added'} and $d->{'diff'}->[1]->{'added'} == 1
);

ok($d = diff([ 0, 1 ], [ 0 ], 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 2 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'common'} and $d->{'diff'}->[0]->{'common'} == 0 and
    keys %{$d->{'diff'}->[1]} == 1 and exists $d->{'diff'}->[1]->{'removed'} and $d->{'diff'}->[1]->{'removed'} == 1
);

ok($d = diff([[[ 0 ]]], [[[ 0 ]]], 'detailed' => 1, 'depth' => 2) and # don't descend deeper than second level
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 1 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'diff'} and @{$d->{'diff'}->[0]->{'diff'}} == 1 and
        keys %{$d->{'diff'}->[0]->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'} and # arrays have different refs
            @{$d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}} == 2 and
            @{$d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[0]} == 1 and
                $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[0]->[0] == 0 and
            @{$d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[1]} == 1 and
                $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[1]->[0] == 0
);

ok($d = diff([[[ 0 ]]], [[[ 0 ]]], 'detailed' => 1, 'depth' => 3) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 1 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'diff'} and @{$d->{'diff'}->[0]->{'diff'}} == 1 and
        keys %{$d->{'diff'}->[0]->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'diff'}->[0]->{'diff'} and
            @{$d->{'diff'}->[0]->{'diff'}->[0]->{'diff'}} == 1 and
            keys %{$d->{'diff'}->[0]->{'diff'}->[0]->{'diff'}->[0]} == 1 and
                exists $d->{'diff'}->[0]->{'diff'}->[0]->{'diff'}->[0]->{'common'} and
                    $d->{'diff'}->[0]->{'diff'}->[0]->{'diff'}->[0]->{'common'} == 0
);

ok($d = diff([ 0 ], [ 0, 1 ], 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 1 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'added'} and $d->{'diff'}->[0]->{'added'} == 1
);

ok($d = diff([ 0, 1 ], [ 0 ], 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 1 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'removed'} and $d->{'diff'}->[0]->{'removed'} == 1
);

my $sub_array = [ 0, [ 11, 12 ], 2 ]; # must be considered as equal by ref (wo descending into it)
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b, 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 5 and (grep { keys %{$_} } @{$d->{'diff'}}) == 5 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'common'} and $d->{'diff'}->[0]->{'common'} == 0 and
    keys %{$d->{'diff'}->[1]} == 1 and exists $d->{'diff'}->[1]->{'diff'} and @{$d->{'diff'}->[1]->{'diff'}} == 1 and
        exists $d->{'diff'}->[1]->{'diff'}->[0]->{'diff'} and @{$d->{'diff'}->[1]->{'diff'}->[0]->{'diff'}} == 1 and
        keys %{$d->{'diff'}->[1]->{'diff'}->[0]->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[1]->{'diff'}->[0]->{'diff'}->[0]->{'common'} and
        $d->{'diff'}->[1]->{'diff'}->[0]->{'diff'}->[0]->{'common'} == 100 and
    keys %{$d->{'diff'}->[2]} == 1 and exists $d->{'diff'}->[2]->{'diff'} and @{$d->{'diff'}->[2]->{'diff'}} == 2 and
        keys %{$d->{'diff'}->[2]->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[2]->{'diff'}->[0]->{'common'} and
            $d->{'diff'}->[2]->{'diff'}->[0]->{'common'} == 20 and
        keys %{$d->{'diff'}->[2]->{'diff'}->[1]} == 1 and exists $d->{'diff'}->[2]->{'diff'}->[1]->{'changed'} and
            @{$d->{'diff'}->[2]->{'diff'}->[1]->{'changed'}} == 2 and
            $d->{'diff'}->[2]->{'diff'}->[1]->{'changed'}->[0] eq 'a' and
            $d->{'diff'}->[2]->{'diff'}->[1]->{'changed'}->[1] eq 'b' and
    keys %{$d->{'diff'}->[3]} == 1 and exists $d->{'diff'}->[3]->{'common'} and @{$d->{'diff'}->[3]->{'common'}} == 3 and
        $d->{'diff'}->[3]->{'common'}->[0] == 0 and
        @{$d->{'diff'}->[3]->{'common'}->[1]} == 2 and
            $d->{'diff'}->[3]->{'common'}->[1]->[0] == 11 and
            $d->{'diff'}->[3]->{'common'}->[1]->[1] == 12 and
        $d->{'diff'}->[3]->{'common'}->[2] == 2 and
    keys %{$d->{'diff'}->[4]} == 1 and exists $d->{'diff'}->[4]->{'changed'} and @{$d->{'diff'}->[4]->{'changed'}} == 2 and
        $d->{'diff'}->[4]->{'changed'}->[0] == 4 and
        $d->{'diff'}->[4]->{'changed'}->[1] == 5
);

ok($d = diff($a, $b, 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 2 and
    keys %{$d->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'diff'} and @{$d->{'diff'}->[0]->{'diff'}} == 1 and
        keys %{$d->{'diff'}->[0]->{'diff'}->[0]} == 1 and exists $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'} and
            @{$d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}} == 2 and
            $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[0] eq 'a' and
            $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[1] eq 'b' and
    keys %{$d->{'diff'}->[1]} == 1 and exists $d->{'diff'}->[1]->{'changed'} and @{$d->{'diff'}->[1]->{'changed'}} == 2 and
        $d->{'diff'}->[1]->{'changed'}->[0] == 4 and
        $d->{'diff'}->[1]->{'changed'}->[1] == 5
);

ok($d = diff($a, $b, 'detailed' => 1, 'nocommon' => 1, 'positions' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and @{$d->{'diff'}} == 2 and
    keys %{$d->{'diff'}->[0]} == 2 and
        exists $d->{'diff'}->[0]->{'diff'} and @{$d->{'diff'}->[0]->{'diff'}} == 1 and
            keys %{$d->{'diff'}->[0]->{'diff'}->[0]} == 2 and
                exists $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'} and @{$d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}} == 2 and
                    $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[0] eq 'a' and
                    $d->{'diff'}->[0]->{'diff'}->[0]->{'changed'}->[1] eq 'b' and
                exists $d->{'diff'}->[0]->{'diff'}->[0]->{'position'} and
                    $d->{'diff'}->[0]->{'diff'}->[0]->{'position'} == 1 and
        exists $d->{'diff'}->[0]->{'position'} and
            $d->{'diff'}->[0]->{'position'} == 2 and
    keys %{$d->{'diff'}->[1]} == 2 and
        exists $d->{'diff'}->[1]->{'changed'} and @{$d->{'diff'}->[1]->{'changed'}} == 2 and
            $d->{'diff'}->[1]->{'changed'}->[0] == 4 and
            $d->{'diff'}->[1]->{'changed'}->[1] == 5 and
        exists $d->{'diff'}->[1]->{'changed'} and
            $d->{'diff'}->[1]->{'position'} == 4
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged

### hashes ###

ok($d = diff({ 'a' => { 'b' => { 'c' => 0 }}}, { 'a' => { 'b' => { 'c' => 0 }}}, 'detailed' => 1, 'depth' => 2) and # don't descend deeper than second level
    keys %{$d} == 1 and exists $d->{'diff'} and keys %{$d->{'diff'}} == 1 and exists $d->{'diff'}->{'a'} and
        keys %{$d->{'diff'}->{'a'}} == 1 and exists $d->{'diff'}->{'a'}->{'diff'} and
            keys %{$d->{'diff'}->{'a'}->{'diff'}} == 1 and exists $d->{'diff'}->{'a'}->{'diff'}->{'b'} and
                keys %{$d->{'diff'}->{'a'}->{'diff'}->{'b'}} == 1 and exists $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'} and
                    @{$d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}} == 2 and
                    keys %{$d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}->[0]} == 1 and
                        exists $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}->[0]->{'c'} and
                            $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}->[0]->{'c'} == 0 and
                    keys %{$d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}->[1]} == 1 and
                        exists $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}->[1]->{'c'} and
                            $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'changed'}->[0]->{'c'} == 0
);

ok($d = diff({ 'a' => { 'b' => { 'c' => 0 }}}, { 'a' => { 'b' => { 'c' => 0 }}}, 'detailed' => 1, 'depth' => 3) and
    keys %{$d} == 1 and exists $d->{'diff'} and keys %{$d->{'diff'}} == 1 and exists $d->{'diff'}->{'a'} and
        keys %{$d->{'diff'}->{'a'}} == 1 and exists $d->{'diff'}->{'a'}->{'diff'} and
            keys %{$d->{'diff'}->{'a'}->{'diff'}} == 1 and exists $d->{'diff'}->{'a'}->{'diff'}->{'b'} and
                keys %{$d->{'diff'}->{'a'}->{'diff'}->{'b'}} == 1 and exists $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'diff'} and
                    keys %{$d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'diff'}} == 1 and
                        exists $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'diff'}->{'c'} and
                        keys %{$d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'diff'}->{'c'}} == 1 and
                            exists $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'diff'}->{'c'}->{'common'} and
                                $d->{'diff'}->{'a'}->{'diff'}->{'b'}->{'diff'}->{'c'}->{'common'} == 0
);

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b, 'detailed' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and keys %{$d->{'diff'}} == 4 and
    keys %{$d->{'diff'}->{'a'}} == 1 and exists $d->{'diff'}->{'a'}->{'common'} and $d->{'diff'}->{'a'}->{'common'} eq 'a1' and
    keys %{$d->{'diff'}->{'b'}} == 1 and exists $d->{'diff'}->{'b'}->{'diff'} and
        keys %{$d->{'diff'}->{'b'}->{'diff'}} == 2 and
        exists $d->{'diff'}->{'b'}->{'diff'}->{'ba'} and keys %{$d->{'diff'}->{'b'}->{'diff'}->{'ba'}} == 1 and
            exists $d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'} and
            @{$d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}} == 2 and
            $d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[0] eq 'ba1' and
            $d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[1] eq 'ba2' and
        exists $d->{'diff'}->{'b'}->{'diff'}->{'bb'} and keys %{$d->{'diff'}->{'b'}->{'diff'}->{'bb'}} == 1 and
            exists $d->{'diff'}->{'b'}->{'diff'}->{'bb'}->{'common'} and
            $d->{'diff'}->{'b'}->{'diff'}->{'bb'}->{'common'} eq 'bb1' and
    keys %{$d->{'diff'}->{'c'}} == 1 and exists $d->{'diff'}->{'c'}->{'removed'} and $d->{'diff'}->{'c'}->{'removed'} eq 'c1' and
    keys %{$d->{'diff'}->{'d'}} == 1 and exists $d->{'diff'}->{'d'}->{'added'} and $d->{'diff'}->{'d'}->{'added'} eq 'd1'
);

ok($d = diff($a, $b, 'detailed' => 1, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'diff'} and keys %{$d->{'diff'}} == 3 and
    keys %{$d->{'diff'}->{'b'}} == 1 and exists $d->{'diff'}->{'b'}->{'diff'} and
        keys %{$d->{'diff'}->{'b'}->{'diff'}} == 1 and
        exists $d->{'diff'}->{'b'}->{'diff'}->{'ba'} and keys %{$d->{'diff'}->{'b'}->{'diff'}->{'ba'}} == 1 and
            exists $d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'} and
            @{$d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}} == 2 and
            $d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[0] eq 'ba1' and
            $d->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[1] eq 'ba2' and
    keys %{$d->{'diff'}->{'c'}} == 1 and exists $d->{'diff'}->{'c'}->{'removed'} and $d->{'diff'}->{'c'}->{'removed'} eq 'c1' and
    keys %{$d->{'diff'}->{'d'}} == 1 and exists $d->{'diff'}->{'d'}->{'added'} and $d->{'diff'}->{'d'}->{'added'} eq 'd1'
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged
