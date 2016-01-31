#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone);
use Test::More tests => 7;

use Struct::Diff qw(diff);

my $diff;

### primitives ###
ok($diff = diff(1, 2, 'detailed' => 1) and
    keys %{$diff} == 1 and exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] == 1 and
    $diff->{'changed'}->[1] == 2
);

### arrays ###
ok($diff = diff([ 0 ], [ 0, 1 ], 'detailed' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'diff'} and @{$diff->{'diff'}} == 2 and
    keys %{$diff->{'diff'}->[0]} == 1 and exists $diff->{'diff'}->[0]->{'common'} and $diff->{'diff'}->[0]->{'common'} == 0 and
    keys %{$diff->{'diff'}->[1]} == 1 and exists $diff->{'diff'}->[1]->{'added'} and $diff->{'diff'}->[1]->{'added'} == 1
);

ok($diff = diff([ 0, 1 ], [ 0 ], 'detailed' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'diff'} and @{$diff->{'diff'}} == 2 and
    keys %{$diff->{'diff'}->[0]} == 1 and exists $diff->{'diff'}->[0]->{'common'} and $diff->{'diff'}->[0]->{'common'} == 0 and
    keys %{$diff->{'diff'}->[1]} == 1 and exists $diff->{'diff'}->[1]->{'removed'} and $diff->{'diff'}->[1]->{'removed'} == 1
);

my $sub_array = [ 0, [ 11, 12 ], 2 ]; # must be considered as equal by ref (wo descending into it)
my $s_array_1 = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
my $s_array_2 = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];
ok($diff = diff($s_array_1, $s_array_2, 'detailed' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'diff'} and @{$diff->{'diff'}} == 5 and
    (grep { keys %{$_} } @{$diff->{'diff'}}) == 5 and
    keys %{$diff->{'diff'}->[0]} == 1 and exists $diff->{'diff'}->[0]->{'common'} and $diff->{'diff'}->[0]->{'common'} == 0 and
    keys %{$diff->{'diff'}->[1]} == 1 and exists $diff->{'diff'}->[1]->{'diff'} and @{$diff->{'diff'}->[1]->{'diff'}} == 1 and
        exists $diff->{'diff'}->[1]->{'diff'}->[0]->{'diff'} and @{$diff->{'diff'}->[1]->{'diff'}->[0]->{'diff'}} == 1 and
        keys %{$diff->{'diff'}->[1]->{'diff'}->[0]->{'diff'}->[0]} == 1 and exists $diff->{'diff'}->[1]->{'diff'}->[0]->{'diff'}->[0]->{'common'} and
        $diff->{'diff'}->[1]->{'diff'}->[0]->{'diff'}->[0]->{'common'} == 100 and
    keys %{$diff->{'diff'}->[2]} == 1 and exists $diff->{'diff'}->[2]->{'diff'} and @{$diff->{'diff'}->[2]->{'diff'}} == 2 and
        keys %{$diff->{'diff'}->[2]->{'diff'}->[0]} == 1 and exists $diff->{'diff'}->[2]->{'diff'}->[0]->{'common'} and
            $diff->{'diff'}->[2]->{'diff'}->[0]->{'common'} == 20 and
        keys %{$diff->{'diff'}->[2]->{'diff'}->[1]} == 1 and exists $diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'} and
            @{$diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'}} == 2 and
            $diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'}->[0] eq 'a' and
            $diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'}->[1] eq 'b' and
    keys %{$diff->{'diff'}->[3]} == 1 and exists $diff->{'diff'}->[3]->{'common'} and @{$diff->{'diff'}->[3]->{'common'}} == 3 and
        $diff->{'diff'}->[3]->{'common'}->[0] == 0 and
        @{$diff->{'diff'}->[3]->{'common'}->[1]} == 2 and
            $diff->{'diff'}->[3]->{'common'}->[1]->[0] == 11 and
            $diff->{'diff'}->[3]->{'common'}->[1]->[1] == 12 and
        $diff->{'diff'}->[3]->{'common'}->[2] == 2 and
    keys %{$diff->{'diff'}->[4]} == 1 and exists $diff->{'diff'}->[4]->{'changed'} and @{$diff->{'diff'}->[4]->{'changed'}} == 2 and
        $diff->{'diff'}->[4]->{'changed'}->[0] == 4 and
        $diff->{'diff'}->[4]->{'changed'}->[1] == 5
);

ok($diff = diff($s_array_1, $s_array_2, 'detailed' => 1, 'shortest' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'diff'} and @{$diff->{'diff'}} == 5 and
    keys %{$diff->{'diff'}->[0]} == 0 and
    keys %{$diff->{'diff'}->[1]} == 0 and
    keys %{$diff->{'diff'}->[2]} == 1 and exists $diff->{'diff'}->[2]->{'diff'} and @{$diff->{'diff'}->[2]->{'diff'}} == 2 and
        keys %{$diff->{'diff'}->[2]->{'diff'}->[0]} == 0 and
        keys %{$diff->{'diff'}->[2]->{'diff'}->[1]} == 1 and exists $diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'} and
            @{$diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'}} == 2 and
            $diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'}->[0] eq 'a' and
            $diff->{'diff'}->[2]->{'diff'}->[1]->{'changed'}->[1] eq 'b' and
    keys %{$diff->{'diff'}->[3]} == 0 and
    keys %{$diff->{'diff'}->[4]} == 1 and exists $diff->{'diff'}->[4]->{'changed'} and @{$diff->{'diff'}->[4]->{'changed'}} == 2 and
        $diff->{'diff'}->[4]->{'changed'}->[0] == 4 and
        $diff->{'diff'}->[4]->{'changed'}->[1] == 5
);

### hashes ###
my $s_hash_1 = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
my $s_hash_2 = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };
ok($diff = diff($s_hash_1, $s_hash_2, 'detailed' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'diff'} and keys %{$diff->{'diff'}} == 4 and
    keys %{$diff->{'diff'}->{'a'}} == 1 and exists $diff->{'diff'}->{'a'}->{'common'} and $diff->{'diff'}->{'a'}->{'common'} eq 'a1' and
    keys %{$diff->{'diff'}->{'b'}} == 1 and exists $diff->{'diff'}->{'b'}->{'diff'} and
        keys %{$diff->{'diff'}->{'b'}->{'diff'}} == 2 and
        exists $diff->{'diff'}->{'b'}->{'diff'}->{'ba'} and keys %{$diff->{'diff'}->{'b'}->{'diff'}->{'ba'}} == 1 and
            exists $diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'} and
            @{$diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}} == 2 and
            $diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[0] eq 'ba1' and
            $diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[1] eq 'ba2' and
        exists $diff->{'diff'}->{'b'}->{'diff'}->{'bb'} and keys %{$diff->{'diff'}->{'b'}->{'diff'}->{'bb'}} == 1 and
            exists $diff->{'diff'}->{'b'}->{'diff'}->{'bb'}->{'common'} and
            $diff->{'diff'}->{'b'}->{'diff'}->{'bb'}->{'common'} eq 'bb1' and
    keys %{$diff->{'diff'}->{'c'}} == 1 and exists $diff->{'diff'}->{'c'}->{'removed'} and $diff->{'diff'}->{'c'}->{'removed'} eq 'c1' and
    keys %{$diff->{'diff'}->{'d'}} == 1 and exists $diff->{'diff'}->{'d'}->{'added'} and $diff->{'diff'}->{'d'}->{'added'} eq 'd1'
);

ok($diff = diff($s_hash_1, $s_hash_2, 'detailed' => 1, 'shortest' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'diff'} and keys %{$diff->{'diff'}} == 3 and
    keys %{$diff->{'diff'}->{'b'}} == 1 and exists $diff->{'diff'}->{'b'}->{'diff'} and
        keys %{$diff->{'diff'}->{'b'}->{'diff'}} == 1 and
        exists $diff->{'diff'}->{'b'}->{'diff'}->{'ba'} and keys %{$diff->{'diff'}->{'b'}->{'diff'}->{'ba'}} == 1 and
            exists $diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'} and
            @{$diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}} == 2 and
            $diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[0] eq 'ba1' and
            $diff->{'diff'}->{'b'}->{'diff'}->{'ba'}->{'changed'}->[1] eq 'ba2' and
    keys %{$diff->{'diff'}->{'c'}} == 1 and exists $diff->{'diff'}->{'c'}->{'removed'} and $diff->{'diff'}->{'c'}->{'removed'} eq 'c1' and
    keys %{$diff->{'diff'}->{'d'}} == 1 and exists $diff->{'diff'}->{'d'}->{'added'} and $diff->{'diff'}->{'d'}->{'added'} eq 'd1'
);
