#!perl -T

use strict;
use warnings FATAL => 'all';
use Struct::Diff qw(diff patch);
use Test::More tests => 2;

### primitives ###
my ($a, $b);

($a, $b) = (0, 1);
patch(\$a, diff($a, $b));
ok($a == $b);

### arrays ###

($a, $b) = ([ 0, 1 ], [ 0 ]);
patch($a, diff($a, $b, trimR => 1));
is_deeply($a, $b, "ARRAY: removed item, trimmedR");

