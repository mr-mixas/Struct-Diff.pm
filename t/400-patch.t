#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 14;

use Struct::Diff qw(diff patch);

use lib "t";
use _common qw(scmp);

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
ok(patch($a, $d) and scmp($a, $b, "ARRAY: Added item"));

($a, $b) = ([ 0, 1 ], [ 0 ]);
$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "ARRAY: removed item"));

($a, $b) = ([ 0, 1 ], [ 0 ], 'trimR' => 1);
$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "ARRAY: removed item, trimmedR"));

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "ARRAY: ext common link"));

$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ]; # restore $a
$d = diff($a, $b, 'noU' => 1);
ok(patch($a, $d) and scmp($a, $b, "ARRAY: same, but patch doesn't contain Unchanged"));

### hashes ###
($a, $b) = ({ 'a' => 'av' }, { 'a' => 'av', 'b' => 'bv' });
$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "HASH: added key"));

($a, $b) = ({ 'a' => 'av', 'b' => 'bv' }, { 'a' => 'av' });
$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "HASH: removed key"));

($a, $b) = ({ 'a' => 'av', 'b' => 'bv' }, { 'a' => 'av' });
$d = diff($a, $b, 'trimR' => 1);
ok(patch($a, $d) and scmp($a, $b, "HASH: removed key, trimmedR"));

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "HASH: complex test"));

### mixed structures ###
$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8 ]};
$b = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 3 ]}}, 8 ]};

$d = diff($a, $b);
ok(patch($a, $d) and scmp($a, $b, "MIXED: complex"));

$a = { 'a' => [ { 'aa' => { 'aaa' => [ 7, 4 ]}}, 8 ]}; # restore a

$d = diff($a, $b, 'noO' => 1, 'noU' => 1);
ok(patch($a, $d) and scmp($a, $b, "MIXED: same, but patch doesn't contain Unchanged"));
