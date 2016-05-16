#!/usr/bin/env perl

use strict;
use warnings;
use Storable qw(freeze);
use Test::More tests => 30;

use Struct::Diff qw(diff);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_a, $frozen_b);

### arrays ###
ok($d = diff([], [ 1 ]) and
    keys %{$d} == 1 and exists $d->{'A'} and @{$d->{'A'}} == 1 and $d->{'A'}->[0] == 1
);

ok($d = diff([], [ 1 ], 'noA' => 1) and
    keys %{$d} == 0
);

ok($d = diff([ 1 ], []) and
    keys %{$d} == 1 and exists $d->{'R'} and @{$d->{'R'}} == 1 and $d->{'R'}->[0] == 1
);

ok($d = diff([ 1 ], [], 'noR' => 1) and
    keys %{$d} == 0
);

ok($d = diff([[[[[ 0, 1 ]]]]], [], 'trimR' => 1) and
    keys %{$d} == 1 and
        exists $d->{'R'} and @{$d->{'R'}} == 1 and not defined $d->{'R'}->[0]
);

ok($d = diff([ 0, [[[[ 0, 1 ]]]]], [ 0 ], 'trimR' => 1) and
    keys %{$d} == 1 and
        exists $d->{'D'} and @{$d->{'D'}} == 2 and
            keys %{$d->{'D'}->[0]} == 1 and
                exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
            keys %{$d->{'D'}->[1]} == 1 and
                exists $d->{'D'}->[1]->{'R'} and not defined $d->{'D'}->[1]->{'R'}
);

ok($d = diff([ 'a' ], [ 'b' ], 'noO' => 1) and
    keys %{$d} == 1 and
        exists $d->{'N'} and @{$d->{'N'}} == 1 and $d->{'N'}->[0] eq 'b'
);

ok($d = diff([ 'a' ], [ 'b' ], 'noN' => 1) and
    keys %{$d} == 1 and
        exists $d->{'O'} and @{$d->{'O'}} == 1 and $d->{'O'}->[0] eq 'a'
);

ok($d = diff([ 0 ], [ 0, 1 ]) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'A'} and $d->{'D'}->[1]->{'A'} == 1
);

ok($d = diff([ 0, 1 ], [ 0 ]) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'R'} and $d->{'D'}->[1]->{'R'} == 1
);

ok($d = diff([ 0 ], [ 0, 1 ], 'noU' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 1 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'A'} and $d->{'D'}->[0]->{'A'} == 1
);

ok($d = diff([ 0, 1 ], [ 0 ], 'noU' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 1 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'R'} and $d->{'D'}->[0]->{'R'} == 1
);

my $sub_array = [ 0, [ 11, 12 ], 2 ]; # must be considered as equal by ref (wo descending into it)
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 5 and (grep { keys %{$_} } @{$d->{'D'}}) == 5 and
    keys %{$d->{'D'}->[0]} == 1 and exists $d->{'D'}->[0]->{'U'} and $d->{'D'}->[0]->{'U'} == 0 and
    keys %{$d->{'D'}->[1]} == 1 and exists $d->{'D'}->[1]->{'U'} and @{$d->{'D'}->[1]->{'U'}} == 1 and
        @{$d->{'D'}->[1]->{'U'}->[0]} == 1 and $d->{'D'}->[1]->{'U'}->[0]->[0] == 100 and
    keys %{$d->{'D'}->[2]} == 1 and exists $d->{'D'}->[2]->{'D'} and @{$d->{'D'}->[2]->{'D'}} == 2 and
        keys %{$d->{'D'}->[2]->{'D'}->[0]} == 1 and exists $d->{'D'}->[2]->{'D'}->[0]->{'U'} and
            $d->{'D'}->[2]->{'D'}->[0]->{'U'} == 20 and
        keys %{$d->{'D'}->[2]->{'D'}->[1]} == 2 and
            exists $d->{'D'}->[2]->{'D'}->[1]->{'O'} and $d->{'D'}->[2]->{'D'}->[1]->{'O'} eq 'a' and
            exists $d->{'D'}->[2]->{'D'}->[1]->{'N'} and $d->{'D'}->[2]->{'D'}->[1]->{'N'} eq 'b' and
    keys %{$d->{'D'}->[3]} == 1 and exists $d->{'D'}->[3]->{'U'} and @{$d->{'D'}->[3]->{'U'}} == 3 and
        $d->{'D'}->[3]->{'U'}->[0] == 0 and
        @{$d->{'D'}->[3]->{'U'}->[1]} == 2 and
            $d->{'D'}->[3]->{'U'}->[1]->[0] == 11 and
            $d->{'D'}->[3]->{'U'}->[1]->[1] == 12 and
        $d->{'D'}->[3]->{'U'}->[2] == 2 and
     keys %{$d->{'D'}->[4]} == 2 and
        exists $d->{'D'}->[4]->{'O'} and $d->{'D'}->[4]->{'O'} == 4 and
        exists $d->{'D'}->[4]->{'N'} and $d->{'D'}->[4]->{'N'} == 5
);

ok($d = diff($a, $b, 'noU' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and @{$d->{'D'}} == 2 and
        keys %{$d->{'D'}->[0]} == 2 and
            exists $d->{'D'}->[0]->{'D'} and exists $d->{'D'}->[0]->{'I'} and $d->{'D'}->[0]->{'I'} == 2 and
                @{$d->{'D'}->[0]->{'D'}} == 1 and
                    exists $d->{'D'}->[0]->{'D'}->[0]->{'I'} and $d->{'D'}->[0]->{'D'}->[0]->{'I'} == 1  and
                    exists $d->{'D'}->[0]->{'D'}->[0]->{'O'} and $d->{'D'}->[0]->{'D'}->[0]->{'O'} eq 'a' and
                    exists $d->{'D'}->[0]->{'D'}->[0]->{'N'} and $d->{'D'}->[0]->{'D'}->[0]->{'N'} eq 'b' and
        keys %{$d->{'D'}->[1]} == 3 and
            exists $d->{'D'}->[1]->{'I'} and $d->{'D'}->[1]->{'I'} == 4 and
            exists $d->{'D'}->[1]->{'O'} and $d->{'D'}->[1]->{'O'} == 4 and
            exists $d->{'D'}->[1]->{'N'} and $d->{'D'}->[1]->{'N'} == 5
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged

### hashes ###
ok($d = diff({}, { 'a' => 'va' }) and
    keys %{$d} == 1 and exists $d->{'A'} and keys %{$d->{'A'}} == 1 and
        exists $d->{'A'}->{'a'} and $d->{'A'}->{'a'} eq 'va'
);

ok($d = diff({}, { 'a' => 'va' }, 'noA' => 1) and
    keys %{$d} == 0
);

ok($d = diff({ 'a' => 'va' }, {}) and
    keys %{$d} == 1 and exists $d->{'R'} and keys %{$d->{'R'}} == 1 and
        exists $d->{'R'}->{'a'} and $d->{'R'}->{'a'} eq 'va'
);

ok($d = diff({ 'a' => 'va' }, {}, 'noR' => 1) and
    keys %{$d} == 0
);

ok($d = diff({ 'a' => { 'aa' => { 'aaa' => 'vaaaa' }}}, {}, 'trimR' => 1) and
    keys %{$d} == 1 and
        exists $d->{'R'} and keys %{$d->{'R'}} == 1 and
            exists $d->{'R'}->{'a'} and not defined $d->{'R'}->{'a'}
);

ok($d = diff({ 'a' => { 'aa' => { 'aaa' => 'vaaaa' }}, 'b' => 'vb'}, { 'b' => 'vb' }, 'trimR' => 1) and
    keys %{$d} == 1 and
        exists $d->{'D'} and keys %{$d->{'D'}} == 2 and
            exists $d->{'D'}->{'a'} and keys %{$d->{'D'}->{'a'}} == 1 and
                exists $d->{'D'}->{'a'}->{'R'} and not defined $d->{'D'}->{'a'}->{'R'} and
            exists $d->{'D'}->{'b'} and keys %{$d->{'D'}->{'b'}} == 1 and
                exists $d->{'D'}->{'b'}->{'U'} and $d->{'D'}->{'b'}->{'U'} eq 'vb'
);

ok($d = diff({ 'a' => 'va' }, { 'a' => 'vb' }, 'noO' => 1) and
    keys %{$d} == 1 and
        exists $d->{'N'} and keys %{$d->{'N'}} == 1 and
            exists $d->{'N'}->{'a'} and $d->{'N'}->{'a'} eq 'vb'
);

ok($d = diff({ 'a' => 'va' }, { 'a' => 'vb' }, 'noN' => 1) and
    keys %{$d} == 1 and
        exists $d->{'O'} and keys %{$d->{'O'}} == 1 and
            exists $d->{'O'}->{'a'} and $d->{'O'}->{'a'} eq 'va'
);

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$frozen_a = freeze($a);
$frozen_b = freeze($b);

ok($d = diff($a, $b) and
    keys %{$d} == 1 and exists $d->{'D'} and keys %{$d->{'D'}} == 4 and
    keys %{$d->{'D'}->{'a'}} == 1 and exists $d->{'D'}->{'a'}->{'U'} and $d->{'D'}->{'a'}->{'U'} eq 'a1' and
    keys %{$d->{'D'}->{'b'}} == 1 and exists $d->{'D'}->{'b'}->{'D'} and
        keys %{$d->{'D'}->{'b'}->{'D'}} == 2 and
        exists $d->{'D'}->{'b'}->{'D'}->{'ba'} and keys %{$d->{'D'}->{'b'}->{'D'}->{'ba'}} == 2 and
            exists $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'O'} and $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'O'} eq 'ba1' and
            exists $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'N'} and $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'N'} eq 'ba2' and
        exists $d->{'D'}->{'b'}->{'D'}->{'bb'} and keys %{$d->{'D'}->{'b'}->{'D'}->{'bb'}} == 1 and
            exists $d->{'D'}->{'b'}->{'D'}->{'bb'}->{'U'} and
            $d->{'D'}->{'b'}->{'D'}->{'bb'}->{'U'} eq 'bb1' and
    keys %{$d->{'D'}->{'c'}} == 1 and exists $d->{'D'}->{'c'}->{'R'} and $d->{'D'}->{'c'}->{'R'} eq 'c1' and
    keys %{$d->{'D'}->{'d'}} == 1 and exists $d->{'D'}->{'d'}->{'A'} and $d->{'D'}->{'d'}->{'A'} eq 'd1'
);

ok($d = diff($a, $b, 'noU' => 1) and
    keys %{$d} == 1 and exists $d->{'D'} and keys %{$d->{'D'}} == 3 and
    keys %{$d->{'D'}->{'b'}} == 1 and exists $d->{'D'}->{'b'}->{'D'} and
        keys %{$d->{'D'}->{'b'}->{'D'}} == 1 and
            exists $d->{'D'}->{'b'}->{'D'}->{'ba'} and keys %{$d->{'D'}->{'b'}->{'D'}->{'ba'}} == 2 and
                keys %{$d->{'D'}->{'b'}->{'D'}->{'ba'}} == 2 and
                    exists $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'O'} and
                        $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'O'} eq 'ba1' and
                    exists $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'N'} and
                        $d->{'D'}->{'b'}->{'D'}->{'ba'}->{'N'} eq 'ba2' and
    keys %{$d->{'D'}->{'c'}} == 1 and exists $d->{'D'}->{'c'}->{'R'} and $d->{'D'}->{'c'}->{'R'} eq 'c1' and
    keys %{$d->{'D'}->{'d'}} == 1 and exists $d->{'D'}->{'d'}->{'A'} and $d->{'D'}->{'d'}->{'A'} eq 'd1'
);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged

### mixed structures ###
$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8 ]};
$b = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 3 ]}}, 8 ]};

$frozen_a = freeze($a);
$frozen_b = freeze($b);

my ($DaD, $DaD0DaaD);

ok($d = diff($a, $b) and
    keys %{$d} == 1 and exists $d->{'D'} and keys %{$d->{'D'}} == 1 and
        exists $d->{'D'}->{'a'} and keys %{$d->{'D'}->{'a'}} == 1 and exists $d->{'D'}->{'a'}->{'D'} and
        $DaD = $d->{'D'}->{'a'}->{'D'} and @{$DaD} == 2 and
            keys %{$DaD->[0]} == 1 and
                exists $DaD->[0]->{'D'} and keys %{$DaD->[0]->{'D'}} == 1 and
                    exists $DaD->[0]->{'D'}->{'aa'} and keys %{$DaD->[0]->{'D'}->{'aa'}} == 1 and
                        exists $DaD->[0]->{'D'}->{'aa'}->{'D'} and
                        $DaD0DaaD = $DaD->[0]->{'D'}->{'aa'}->{'D'} and keys %{$DaD0DaaD} == 1 and
                            exists $DaD0DaaD->{'aaa'} and keys %{$DaD0DaaD->{'aaa'}} == 1 and
                                exists $DaD0DaaD->{'aaa'}->{'D'} and @{$DaD0DaaD->{'aaa'}->{'D'}} == 2 and
                                    keys %{$DaD0DaaD->{'aaa'}->{'D'}->[0]} == 1 and
                                        exists $DaD0DaaD->{'aaa'}->{'D'}->[0]->{'U'} and
                                            $DaD0DaaD->{'aaa'}->{'D'}->[0]->{'U'} == 7 and
                                    keys %{$DaD0DaaD->{'aaa'}->{'D'}->[1]} == 2 and
                                        exists $DaD0DaaD->{'aaa'}->{'D'}->[1]->{'O'} and
                                            $DaD0DaaD->{'aaa'}->{'D'}->[1]->{'O'} == 4 and
                                        exists $DaD0DaaD->{'aaa'}->{'D'}->[1]->{'N'} and
                                            $DaD0DaaD->{'aaa'}->{'D'}->[1]->{'N'} == 3 and
            keys %{$DaD->[1]} == 1 and
                exists $DaD->[1]->{'U'} and
                    $DaD->[1]->{'U'} == 8
);

ok($d = diff($a, $a, 'noU' => 1) and keys %{$d} == 0);

ok($d = diff($a, $a) and freeze($d->{'U'}) eq $frozen_a);

ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b)); # original structs must remain unchanged
