#!perl -T

use strict;
use warnings;
use Storable qw(freeze);
use Test::More tests => 22;

use Struct::Diff qw(diff dselect);

use lib "t";
use _common qw(scmp);

$Storable::canonical = 1;
my ($a, $b, $d, $frozen_d, $s, @se);

### primitives ###
$d = diff(0, 0);

@se = dselect($d);
ok(scmp(\@se, [{U => 0}], "0 vs 0"));

@se = dselect($d, 'states' => { 'N' => 1 });
ok(scmp(\@se, [], "0 vs 0, N only"));

@se = dselect($d, 'states' => {}); # empty states list - empty result
ok(scmp(\@se, [], "0 vs 0, empty states"));

$d = diff(0, 1);
@se = dselect($d);
ok(scmp(\@se, [{N => 1,O => 0}], "0 vs 1"));

### arrays ###
$d = diff([ 0 ], [ 0, 1 ]);
@se = dselect($d);
ok(scmp(\@se, [{D => [{U => 0},{A => 1}]}], "[0] vs [0,1], noopts"));

@se = dselect($d, 'fromD' => undef); # empty list means from all D
ok(scmp(\@se, [{U => 0},{A => 1}], "[0] vs [0,1], fromD => undef"));

@se = dselect($d, 'fromD' => undef, 'states' => { 'A' => 1 });
ok(scmp(\@se, [{A => 1}], "[0] vs [0,1], fromD => undef, states => {A => 1}"));

$d = diff([ 0, 1 ], [ 0 ]);
@se = dselect($d, 'fromD' => undef);
ok(scmp(\@se, [{U => 0},{R => 1}], "[0,1] vs [0], fromD => undef"));

my $sub_array = [ 0, [ 11, 12 ], 2 ];
$a = [ 0, [[ 100 ]], [ 20, 'a' ], $sub_array, 4 ];
$b = [ 0, [[ 100 ]], [ 20, 'b' ], $sub_array, 5 ];

$d = diff($a, $b);
$frozen_d = freeze($d);
@se = dselect($d, 'fromD' => undef); # select here -- mere extraction from 'D'
ok(scmp(
    \@se,
    [{U => 0},{U => [[100]]},{D => [{U => 20},{N => 'b',O => 'a'}]},{U => [0,[11,12],2]},{N => 5,O => 4}],
    "complex array, fromD => undef"
));

@se = dselect($d, 'states' => {});
ok(scmp(\@se, [], "complex array, empty states"));

@se = dselect($d, 'fromD' => []); # emply list in 'from' means from all D
ok(scmp(
    \@se,
    [{U => 0},{U => [[100]]},{D => [{U => 20},{N => 'b',O => 'a'}]},{U => [0,[11,12],2]},{N => 5,O => 4}],
    "complex array, fromD => []"
));

@se = dselect($d, 'fromD' => [ 0, 4 ]);
ok(scmp(
    \@se,
    [{U => 0},{N => 5,O => 4}],
    "complex array, fromD => [0,4]"
));

@se = dselect($d, 'states' => { 'N' => 1, 'U' => 1 }, 'fromD' => [ 0, 4 ]);
ok(scmp(
    \@se,
    [{U => 0},{N => 5}],
    "complex array, fromD => [0,4], states N and U"
));

@se = dselect($d, 'states' => { 'O' => 1 }, 'fromD' => [ 0, 4 ]);
ok(scmp(
    \@se,
    [{O => 4}],
    "complex array, fromD => [0,4], states O"
));

ok($frozen_d eq freeze($d)); # original struct must remain unchanged

### hashes ###

$a = { 'a' => 'a1', 'b' => { 'ba' => 'ba1', 'bb' => 'bb1' }, 'c' => 'c1' };
$b = { 'a' => 'a1', 'b' => { 'ba' => 'ba2', 'bb' => 'bb1' }, 'd' => 'd1' };

$d = diff($a, $b);
$frozen_d = freeze($d);

@se = dselect($d, 'states' => {});
ok(scmp(\@se, [], "complex hash, empty states list"));

@se = dselect($d, 'fromD' => undef);
ok(freeze($d->{'D'}) eq freeze( { map { %{$_} } @se } ));

@se = dselect($d, 'fromD' => []);
ok(freeze($d->{'D'}) eq freeze( { map { %{$_} } @se } ));

@se = dselect($d, 'fromD' => [ 'd', 'c']);
ok(scmp(
    \@se,
    [{d => {A => 'd1'}},{c => {R => 'c1'}}],
    "complex hash, fromD => [d,c]"
));

@se = dselect($d, 'states' => { 'A' => 1, 'R' => 1 }, 'fromD' => [ 'd', 'c']);
ok(scmp(
    \@se,
    [{d => {A => 'd1'}},{c => {R => 'c1'}}],
    "complex hash, fromD => [d,c], states A and R"
));

@se = dselect($d, 'states' => { 'A' => 1, 'D' => 1 }, 'fromD' => [ 'd', 'c']);
ok(scmp(
    \@se,
    [{d => {A => 'd1'}}],
    "complex hash, fromD => [d,c], states: A"
));

ok($frozen_d eq freeze($d)); # original struct must remain unchanged
