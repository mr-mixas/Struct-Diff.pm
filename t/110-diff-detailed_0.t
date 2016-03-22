#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone freeze);
use Test::More tests => 14;

use Struct::Diff qw(diff);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_a, $frozen_b);

### primitives ###
ok($d = diff(1, 2, 'detailed' => 0) and
    keys %{$d} == 1 and exists $d->{'C'} and @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] == 1 and
    $d->{'C'}->[1] == 2
);

### arrays ###
ok($d = diff([ 0 ], [ 0, 1 ], 'detailed' => 0) and
    keys %{$d} == 2 and
        exists $d->{'A'} and @{$d->{'A'}} == 1 and $d->{'A'}->[0] == 1 and
        exists $d->{'U'} and @{$d->{'U'}} == 1 and $d->{'U'}->[0] == 0
);

ok($d = diff([ 0, 1 ], [ 0 ], 'detailed' => 0) and
    keys %{$d} == 2 and
        exists $d->{'U'} and @{$d->{'U'}} == 1 and $d->{'U'}->[0] == 0 and
        exists $d->{'R'} and @{$d->{'R'}} == 1 and $d->{'R'}->[0] == 1
);

ok($d = diff([ 0 ], [ 0, 1 ], 'detailed' => 0, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'A'} and @{$d->{'A'}} == 1 and $d->{'A'}->[0] == 1
);

ok($d = diff([ 0, 1 ], [ 0 ], 'detailed' => 0, 'nocommon' => 1) and
    keys %{$d} == 1 and exists $d->{'R'} and @{$d->{'R'}} == 1 and $d->{'R'}->[0] == 1
);

ok($d = diff([ 0 ], [ 1 ], 'detailed' => 0, 'separate-changed' => 1) and
    keys %{$d} == 2 and
        exists $d->{'A'} and @{$d->{'A'}} == 1 and $d->{'A'}->[0] == 1 and
        exists $d->{'R'} and @{$d->{'R'}} == 1 and $d->{'R'}->[0] == 0
);

my $sub_array = [ 0, [ 11, 12 ], 2 ]; # must be considered as equal by ref (wo descending into it)
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b, 'detailed' => 0) and
    keys %{$d} == 2 and
        exists $d->{'C'} and @{$d->{'C'}} == 2 and
            @{$d->{'C'}->[0]} == 3 and
                @{$d->{'C'}->[0]->[0]} == 2 and
                    $d->{'C'}->[0]->[0]->[0] == 20 and
                    $d->{'C'}->[0]->[0]->[1] eq 'a' and
                @{$d->{'C'}->[0]->[1]} == 2 and
                    $d->{'C'}->[0]->[1]->[0] == 20 and
                    $d->{'C'}->[0]->[1]->[1] eq 'b' and
                $d->{'C'}->[0]->[2] == 2 and
            @{$d->{'C'}->[1]} == 3 and
                $d->{'C'}->[1]->[0] == 4 and
                $d->{'C'}->[1]->[1] == 5 and
                $d->{'C'}->[1]->[2] == 4 and
        exists $d->{'U'} and @{$d->{'U'}} == 3 and
            $d->{'U'}->[0] == 0 and
            @{$d->{'U'}->[1]} == 1 and @{$d->{'U'}->[1]->[0]} == 1 and
                $d->{'U'}->[1]->[0]->[0] == 100 and
            @{$d->{'U'}->[2]} == 3 and
                $d->{'U'}->[2]->[0] == 0 and
                @{$d->{'U'}->[2]->[1]} == 2 and
                    $d->{'U'}->[2]->[1]->[0] == 11 and
                    $d->{'U'}->[2]->[1]->[1] == 12 and
                $d->{'U'}->[2]->[2] == 2
);

ok($d = diff($a, $b, 'detailed' => 0, 'nocommon' => 1) and
    keys %{$d} == 1 and
        exists $d->{'C'} and @{$d->{'C'}} == 2 and
            @{$d->{'C'}->[0]} == 3 and
                @{$d->{'C'}->[0]->[0]} == 2 and
                    $d->{'C'}->[0]->[0]->[0] == 20 and
                    $d->{'C'}->[0]->[0]->[1] eq 'a' and
                @{$d->{'C'}->[0]->[1]} == 2 and
                    $d->{'C'}->[0]->[1]->[0] == 20 and
                    $d->{'C'}->[0]->[1]->[1] eq 'b' and
                $d->{'C'}->[0]->[2] == 2 and
            @{$d->{'C'}->[1]} == 3 and
                $d->{'C'}->[1]->[0] == 4 and
                $d->{'C'}->[1]->[1] == 5 and
                $d->{'C'}->[1]->[2] == 4
);

ok($d = diff($a, $b, 'detailed' => 0, 'nocommon' => 1) and
    keys %{$d} == 1 and
        exists $d->{'C'} and @{$d->{'C'}} == 2 and
            @{$d->{'C'}->[0]} == 3 and
                @{$d->{'C'}->[0]->[0]} == 2 and
                    $d->{'C'}->[0]->[0]->[0] == 20 and
                    $d->{'C'}->[0]->[0]->[1] eq 'a' and
                @{$d->{'C'}->[0]->[1]} == 2 and
                    $d->{'C'}->[0]->[1]->[0] == 20 and
                    $d->{'C'}->[0]->[1]->[1] eq 'b' and
                $d->{'C'}->[0]->[2] == 2 and
            @{$d->{'C'}->[1]} == 3 and
                $d->{'C'}->[1]->[0] == 4 and
                $d->{'C'}->[1]->[1] == 5 and
                $d->{'C'}->[1]->[2] == 4
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged

### hashes ###

ok($d = diff({ 'a' => 0 }, { 'a' => 1 }, 'detailed' => 0, 'separate-changed' => 1) and
    keys %{$d} == 2 and
        exists $d->{'A'} and keys %{$d->{'A'}} == 1 and exists $d->{'A'}->{'a'} and $d->{'A'}->{'a'} == 1 and
        exists $d->{'R'} and keys %{$d->{'R'}} == 1 and exists $d->{'R'}->{'a'} and $d->{'R'}->{'a'} == 0
);

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b, 'detailed' => 0) and
    keys %{$d} == 4 and
        exists $d->{'A'} and keys %{$d->{'A'}} == 1 and exists $d->{'A'}->{'d'} and $d->{'A'}->{'d'} eq 'd1' and
        exists $d->{'C'} and keys %{$d->{'C'}} == 1 and exists $d->{'C'}->{'b'} and @{$d->{'C'}->{'b'}} == 2 and
            keys %{$d->{'C'}->{'b'}->[0]} == 2 and
                exists $d->{'C'}->{'b'}->[0]->{'ba'} and $d->{'C'}->{'b'}->[0]->{'ba'} eq 'ba1' and
                exists $d->{'C'}->{'b'}->[0]->{'bb'} and $d->{'C'}->{'b'}->[0]->{'bb'} eq 'bb1' and
            keys %{$d->{'C'}->{'b'}->[1]} == 2 and
                exists $d->{'C'}->{'b'}->[1]->{'ba'} and $d->{'C'}->{'b'}->[1]->{'ba'} eq 'ba2' and
                exists $d->{'C'}->{'b'}->[1]->{'bb'} and $d->{'C'}->{'b'}->[1]->{'bb'} eq 'bb1' and
        exists $d->{'R'} and keys %{$d->{'R'}} == 1 and exists $d->{'R'}->{'c'} and $d->{'R'}->{'c'} eq 'c1' and
        exists $d->{'U'} and keys %{$d->{'U'}} == 1 and exists $d->{'U'}->{'a'} and $d->{'U'}->{'a'} eq 'a1'
);

ok($d = diff($a, $b, 'detailed' => 0, 'nocommon' => 1) and
    keys %{$d} == 3 and
        exists $d->{'A'} and keys %{$d->{'A'}} == 1 and exists $d->{'A'}->{'d'} and $d->{'A'}->{'d'} eq 'd1' and
        exists $d->{'C'} and keys %{$d->{'C'}} == 1 and exists $d->{'C'}->{'b'} and @{$d->{'C'}->{'b'}} == 2 and
            keys %{$d->{'C'}->{'b'}->[0]} == 2 and
                exists $d->{'C'}->{'b'}->[0]->{'ba'} and $d->{'C'}->{'b'}->[0]->{'ba'} eq 'ba1' and
                exists $d->{'C'}->{'b'}->[0]->{'bb'} and $d->{'C'}->{'b'}->[0]->{'bb'} eq 'bb1' and
            keys %{$d->{'C'}->{'b'}->[1]} == 2 and
                exists $d->{'C'}->{'b'}->[1]->{'ba'} and $d->{'C'}->{'b'}->[1]->{'ba'} eq 'ba2' and
                exists $d->{'C'}->{'b'}->[1]->{'bb'} and $d->{'C'}->{'b'}->[1]->{'bb'} eq 'bb1' and
        exists $d->{'R'} and keys %{$d->{'R'}} == 1 and exists $d->{'R'}->{'c'} and $d->{'R'}->{'c'} eq 'c1'
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged
