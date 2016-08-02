#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 14;

use Struct::Diff qw(diff dtraverse);

use Storable qw(dclone freeze);
$Storable::canonical = 1;

use lib "t";
use _common qw(scmp sdump);

my ($a, $b, $d, $t);
my $opts = {
    callback => sub { $t->{sdump($_[1])}->{$_[2]} = $_[0]; $t->{TOTAL}++ },
};

$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8, 11 ]};
$b = { 'a' => [ { 'aa' => { 'aab' => [ 7, 3 ]}}, 9, 11 ]};
my $frozen_a = freeze($a);
my $frozen_b = freeze($b);

### no callbacks used ###
$t = undef;
$d = diff($a, $b);
eval { dtraverse($d, {}) };
ok($@ =~ /^Callback must be a code reference/);

# check original structures not changed
ok($frozen_a eq freeze($a) and $frozen_b eq freeze($b));

### primitives ###
($a, $b, $t) = (0, 0, undef);
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp($t, {TOTAL => 1,'[]' => {U => 0}}, "0 vs 0"));

($a, $b, $t) = (0, 0, undef);
$d = diff($a, $b, "noU" => 1);
dtraverse($d, $opts);
ok(scmp($t, undef, "0 vs 0, noU => 1"));

($a, $b, $t) = (0, 1, undef);
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp($t, {TOTAL => 2,'[]' => {N => 1,O => 0}}, "0 vs 1"));

### arrays ###
($a, $b, $t) = ([ 0 ], [ 0, 1 ], undef);
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp($t, {TOTAL => 2,'[[0]]' => {U => 0},'[[1]]' => {A => 1}}, "[0] vs [0,1]"));

($a, $b, $t) = ([ 0, 1 ], [ 0 ], undef);
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp($t, {TOTAL => 2,'[[0]]' => {U => 0},'[[1]]' => {R => 1}}, "[0,1] vs [0]"));

$a = [[ 0, 0 ]];
$b = [[ 1, 0 ]];
$t = undef;
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp($t, {TOTAL => 3,'[[0],[0]]' => {N => 1,O => 0},'[[0],[1]]' => {U => 0}}, "[[[0,0]]] vs [[[1,0]]]"));

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];
$t = undef;

$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp(
    $t,
    {
        TOTAL => 8,
        '[[0]]' => {U => 0},
        '[[1]]' => {U => [[100]]},
        '[[2],[0]]' => {U => 20},
        '[[2],[1]]' => {N => 'b',O => 'a'},'[[3]]' => {U => [0,[11,12],2]},
        '[[4]]' => {N => 5,O => 4}
    },
    "complex array"
));

#### hashes ###
$a = { 'a' => 'av' };
$b = { 'a' => 'av', 'b' => 'bv' };
$t = undef;
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp(
    $t,
    {TOTAL => 2,'[{keys => [\'a\']}]' => {U => 'av'},'[{keys => [\'b\']}]' => {A => 'bv'}},
    "HASH, key added"
));

$a = { 'a' => 'av', 'b' => 'bv' };
$b = { 'a' => 'av' };
$t = undef;
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp(
    $t,
    {TOTAL => 2,'[{keys => [\'a\']}]' => {U => 'av'},'[{keys => [\'b\']}]' => {R => 'bv'}},
    "HASH: removed key"
));

$a = { 'a' => 'av', 'b' => 'bv' };
$b = { 'a' => 'av' };
$t = undef;
$d = diff($a, $b, 'trimR' => 1); # user decision (to trim and have undefs for removed items)
dtraverse($d, $opts);
ok(scmp(
    $t,
    {TOTAL => 2,'[{keys => [\'a\']}]' => {U => 'av'},'[{keys => [\'b\']}]' => {R => undef}},
    "HASH: removed key, trimmedR"
));

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };
$t = undef;
$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp(
    $t,
    {
        TOTAL => 6,
        '[{keys => [\'a\']}]' => {U => 'a1'},
        '[{keys => [\'b\']},{keys => [\'ba\']}]' => {N => 'ba2',O => 'ba1'},
        '[{keys => [\'b\']},{keys => [\'bb\']}]' => {U => 'bb1'},
        '[{keys => [\'c\']}]' => {R => 'c1'},
        '[{keys => [\'d\']}]' => {A => 'd1'}
    },
    "HASH: complex test"
));

#### mixed structures ###
$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8 ]};
$b = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 3 ]}}, 8 ]};
$t = undef;

$d = diff($a, $b);
dtraverse($d, $opts);
ok(scmp(
    $t,
    {
        TOTAL => 4,
        '[{keys => [\'a\']},[0],{keys => [\'aa\']},{keys => [\'aaa\']},[0]]' => {U => 7},
        '[{keys => [\'a\']},[0],{keys => [\'aa\']},{keys => [\'aaa\']},[1]]' => {N => 3,O => 4},
        '[{keys => [\'a\']},[1]]' => {U => 8}
    },
    "MIXED: complex"
));
