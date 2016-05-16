#!/usr/bin/env perl

use strict;
use warnings;
use Data::Compare;
use Storable qw(freeze);
use Test::More tests => 14;

use Struct::Diff qw(diff patch);

$Storable::canonical = 1;
my ($a, $b, $d);

### primitives ###
($a, $b) = (0, 0);
$d = diff($a, $b);
ok(patch(\$a, $d) and $a == $b);

($a, $b) = (0, 0);
$d = diff($a, $b, "noU" => 1);
ok(patch(\$a, $d) and $a == $b);

($a, $b) = (0, 1);
$d = diff($a, $b);
ok(patch(\$a, $d) and $a == $b);

### arrays ###
($a, $b) = ([ 0 ], [ 0, 1 ]);
$d = diff($a, $b);
ok(patch($a, $d) and freeze($a) eq freeze($b));

($a, $b) = ([ 0, 1 ], [ 0 ]);
$d = diff($a, $b);
ok(patch($a, $d) and freeze($a) eq freeze($b));

($a, $b) = ([ 0, 1 ], [ 0 ], 'trimR' => 1);
$d = diff($a, $b);
ok(patch($a, $d) and freeze($a) eq freeze($b));

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$d = diff($a, $b);
ok(patch($a, $d) and Compare($a, $b));

$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ]; # restore $a
$d = diff($a, $b, 'noU' => 1);
ok(patch($a, $d) and Compare($a, $b));

### hashes ###
($a, $b) = ({ 'a' => 'av' }, { 'a' => 'av', 'b' => 'bv' });
$d = diff($a, $b);
ok(patch($a, $d) and freeze($a) eq freeze($b));

($a, $b) = ({ 'a' => 'av', 'b' => 'bv' }, { 'a' => 'av' });
$d = diff($a, $b);
ok(patch($a, $d) and freeze($a) eq freeze($b));

($a, $b) = ({ 'a' => 'av', 'b' => 'bv' }, { 'a' => 'av' });
$d = diff($a, $b, 'trimR' => 1);
ok(patch($a, $d) and freeze($a) eq freeze($b));

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b);
ok(patch($a, $d) and Compare($a, $b));

### mixed structures ###
$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8 ]};
$b = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 3 ]}}, 8 ]};

$d = diff($a, $b);
ok(patch($a, $d) and Compare($a, $b));

$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8 ]}; # restore a

$d = diff($a, $b, 'noO' => 1, 'noU' => 1);
ok(patch($a, $d) and Compare($a, $b));
