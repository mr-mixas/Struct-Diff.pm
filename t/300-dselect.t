#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(freeze);
use Test::More tests => 22;

use Struct::Diff qw(diff dselect);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_d, $s, @se);

### primitives ###
$d = diff(0, 0);

@se = dselect($d);
ok(@se == 1 and keys %{$se[0]} == 1 and exists $se[0]->{'U'} and $se[0]->{'U'} == 0);

@se = dselect($d, 'states' => { 'N' => 1 });
ok(@se == 0);

@se = dselect($d, 'states' => {}); # empty states list - empty result
ok(@se == 0);

$d = diff(0, 1);
@se = dselect($d);
ok(
    @se == 1 and keys %{$se[0]} == 2 and
        exists $se[0]->{'O'} and $se[0]->{'O'} == 0 and
        exists $se[0]->{'N'} and $se[0]->{'N'} == 1
);

### arrays ###
$d = diff([ 0 ], [ 0, 1 ]);
@se = dselect($d);
ok(freeze($d) eq freeze($se[0])); # D returned

@se = dselect($d, 'fromD' => undef); # empty list means from all D
ok(
    @se == 2 and
        keys %{$se[0]} == 1 and exists $se[0]->{'U'} and $se[0]->{'U'} == 0 and
        keys %{$se[1]} == 1 and exists $se[1]->{'A'} and $se[1]->{'A'} == 1
);

@se = dselect($d, 'fromD' => undef, 'states' => { 'A' => 1 });
ok(@se == 1 and keys %{$se[0]} == 1 and exists $se[0]->{'A'} and $se[0]->{'A'} == 1);

$d = diff([ 0, 1 ], [ 0 ]);
@se = dselect($d, 'fromD' => undef);
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
@se = dselect($d, 'fromD' => undef);
ok(freeze($d->{'D'}) eq freeze(\@se)); # select here -- mere extraction from 'D'

@se = dselect($d, 'states' => {});
ok(@se == 0);

@se = dselect($d, 'fromD' => []); # emply list in 'from' means from all D
ok(freeze($d->{'D'}) eq freeze(\@se));

@se = dselect($d, 'fromD' => [ 0, 4 ]);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'U'} and
        $se[0]->{'U'} == 0 and
    keys %{$se[1]} == 2 and
        exists $se[1]->{'O'} and $se[1]->{'O'} == 4 and
        exists $se[1]->{'N'} and $se[1]->{'N'} == 5
);

@se = dselect($d, 'states' => { 'N' => 1, 'U' => 1 }, 'fromD' => [ 0, 4 ]);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'U'} and
        $se[0]->{'U'} == 0 and
    keys %{$se[1]} == 1 and exists $se[1]->{'N'} and
        $se[1]->{'N'} == 5
);

@se = dselect($d, 'states' => { 'O' => 1 }, 'fromD' => [ 0, 4 ]);
ok(
    @se == 1 and keys %{$se[0]} == 1 and
        exists $se[0]->{'O'} and $se[0]->{'O'} == 4
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

### hashes ###

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b);
$frozen_d = freeze($d);

@se = dselect($d, 'states' => {});
ok(@se == 0);

@se = dselect($d, 'fromD' => undef);
ok(freeze($d->{'D'}) eq freeze( { map { %{$_} } @se } ));

@se = dselect($d, 'fromD' => []);
ok(freeze($d->{'D'}) eq freeze( { map { %{$_} } @se } ));

@se = dselect($d, 'fromD' => [ 'd', 'c']);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'d'} and
        keys %{$se[0]->{'d'}} == 1 and exists $se[0]->{'d'}->{'A'} and $se[0]->{'d'}->{'A'} eq 'd1' and
    keys %{$se[1]} == 1 and exists $se[1]->{'c'} and
        keys %{$se[1]->{'c'}} == 1 and exists $se[1]->{'c'}->{'R'} and $se[1]->{'c'}->{'R'} eq 'c1'
);

@se = dselect($d, 'states' => { 'A' => 1, 'R' => 1 }, 'fromD' => [ 'd', 'c']);
ok(
    @se == 2 and
    keys %{$se[0]} == 1 and exists $se[0]->{'d'} and
        keys %{$se[0]->{'d'}} == 1 and exists $se[0]->{'d'}->{'A'} and $se[0]->{'d'}->{'A'} eq 'd1' and
    keys %{$se[1]} == 1 and exists $se[1]->{'c'} and
        keys %{$se[1]->{'c'}} == 1 and exists $se[1]->{'c'}->{'R'} and $se[1]->{'c'}->{'R'} eq 'c1'
);

@se = dselect($d, 'states' => { 'A' => 1, 'D' => 1 }, 'fromD' => [ 'd', 'c']);
ok(
    @se == 1 and
    keys %{$se[0]} == 1 and exists $se[0]->{'d'} and
        keys %{$se[0]->{'d'}} == 1 and exists $se[0]->{'d'}->{'A'} and $se[0]->{'d'}->{'A'} eq 'd1'
);

ok($frozen_d eq freeze($d)); # original struct must remain unchanged
