#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(freeze);
use Test::More tests => 20;

use Struct::Diff qw(diff dselect);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_d, $s, @se);

### primitives ###
$d = diff(0, 0);

@se = dselect($d);
ok(@se == 1 and keys %{$se[0]} == 1 and exists $se[0]->{'U'} and $se[0]->{'U'} == 0);

@se = dselect($d, 'states' => { 'C' => 1 });
ok(@se == 0);

@se = dselect($d, 'states' => {}); # empty states list - empty result
ok(@se == 0);

$d = diff(0, 1);
@se = dselect($d);
ok(
    @se == 1 and keys %{$se[0]} == 1 and exists $se[0]->{'C'} and
    @{$se[0]->{'C'}} == 2 and
        $se[0]->{'C'}->[0] == 0 and
        $se[0]->{'C'}->[1] == 1
);

### arrays ###
$d = diff([ 0 ], [ 0, 1 ]);
@se = dselect($d);
ok(
    @se == 2 and
        keys %{$se[0]} == 1 and exists $se[0]->{'U'} and $se[0]->{'U'} == 0 and
        keys %{$se[1]} == 1 and exists $se[1]->{'A'} and $se[1]->{'A'} == 1
);

@se = dselect($d, 'states' => { 'A' => 1 });
ok(@se == 1 and keys %{$se[0]} == 1 and exists $se[0]->{'A'} and $se[0]->{'A'} == 1);

$d = diff([ 0, 1 ], [ 0 ]);
@se = dselect($d);
ok(
    @se == 2 and
        keys %{$se[0]} == 1 and exists $se[0]->{'U'} and $se[0]->{'U'} == 0 and
        keys %{$se[1]} == 1 and exists $se[1]->{'R'} and $se[1]->{'R'} == 1
);

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$d = diff($a, $b);
$frozen_d = freeze($d);
@se = dselect($d);
ok(freeze($d->{'D'}) eq freeze(\@se)); # select here -- mere extraction from 'D'

@se = dselect($d, 'states' => {});
ok(@se == 0);

@se = dselect($d, 'from' => []);
ok(@se == 0);


@se = dselect($d, 'from' => [ 0, 4 ]);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'U'} and
        $se[0]->{'U'} == 0 and
    keys %{$se[1]} == 1 and exists $se[1]->{'C'} and
        @{$se[1]->{'C'}} == 2 and
            $se[1]->{'C'}->[0] == 4 and
            $se[1]->{'C'}->[1] == 5
);

@se = dselect($d, 'states' => { 'C' => 1, 'U' => 1 }, 'from' => [ 0, 4 ]);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'U'} and
        $se[0]->{'U'} == 0 and
    keys %{$se[1]} == 1 and exists $se[1]->{'C'} and
        @{$se[1]->{'C'}} == 2 and
            $se[1]->{'C'}->[0] == 4 and
            $se[1]->{'C'}->[1] == 5
);

@se = dselect($d, 'states' => { 'C' => 1 }, 'from' => [ 0, 4 ]);
ok(
    @se == 1 and keys %{$se[0]} == 1 and exists $se[0]->{'C'} and
    @{$se[0]->{'C'}} == 2 and
        $se[0]->{'C'}->[0] == 4 and
        $se[0]->{'C'}->[1] == 5
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

### hashes ###

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b);
$frozen_d = freeze($d);

@se = dselect($d, 'states' => {});
ok(@se == 0);

@se = dselect($d, 'from' => []);
ok(@se == 0);

@se = dselect($d, 'from' => [ 'd', 'c']);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'d'} and
        keys %{$se[0]->{'d'}} == 1 and exists $se[0]->{'d'}->{'A'} and $se[0]->{'d'}->{'A'} eq 'd1' and
    keys %{$se[1]} == 1 and exists $se[1]->{'c'} and
        keys %{$se[1]->{'c'}} == 1 and exists $se[1]->{'c'}->{'R'} and $se[1]->{'c'}->{'R'} eq 'c1'
);

@se = dselect($d, 'states' => { 'A' => 1, 'R' => 1 }, 'from' => [ 'd', 'c']);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'d'} and
        keys %{$se[0]->{'d'}} == 1 and exists $se[0]->{'d'}->{'A'} and $se[0]->{'d'}->{'A'} eq 'd1' and
    keys %{$se[1]} == 1 and exists $se[1]->{'c'} and
        keys %{$se[1]->{'c'}} == 1 and exists $se[1]->{'c'}->{'R'} and $se[1]->{'c'}->{'R'} eq 'c1'
);

@se = dselect($d, 'states' => { 'A' => 1, 'D' => 1 }, 'from' => [ 'd', 'c']);
ok(
    @se == 1 and
    keys %{$se[0]} == 1 and exists $se[0]->{'d'} and
        keys %{$se[0]->{'d'}} == 1 and exists $se[0]->{'d'}->{'A'} and $se[0]->{'d'}->{'A'} eq 'd1'
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged
