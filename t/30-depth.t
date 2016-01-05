#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone);
use Test::More tests => 6;

use Struct::Diff;

my $diff;

### arrays ###
my $s_array_1 = [ 0, 1, 2, { '3k0' => '3k0v0', '3k1' => {} }, 4 ];

# same structs, equal refs, must pass
my $s_array_2 = $s_array_1;
ok($diff = diff($s_array_1, $s_array_2, 'depth' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'common'}
);

# cloned, means same data, but different refs, 2-d level structs must be marked as changed
$s_array_2 = dclone($s_array_1);
ok($diff = diff($s_array_1, $s_array_2, 'depth' => 1) and
    keys %{$diff} == 2 and
    exists $diff->{'changed'} and
    exists $diff->{'common'} and
    @{$diff->{'common'}} == 4
);

# new array, same data, same subrefs, must pass
$s_array_2 = [@{$s_array_1}];
ok($diff = diff($s_array_1, $s_array_2, 'depth' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'common'}
);


### hashes ###
my $s_hash_1 = { 'k0' => [ 0, 1, 2 ], 'k1' => { 'k1v0k0' => { 'k1v0k0v0k0' => 'k1v0k0v0k0v0' } }, 'k2' => undef };

# same structs, equal refs, must pass
my $s_hash_2 = $s_hash_1;
ok($diff = diff($s_hash_1, $s_hash_2, 'depth' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'common'}
);

# cloned, means same data, but different refs, 2-d level structs must be marked as changed
$s_hash_2 = dclone($s_hash_1);
ok($diff = diff($s_hash_1, $s_hash_2, 'depth' => 1) and
    keys %{$diff} == 2 and
    exists $diff->{'changed'} and
    exists $diff->{'common'} and
    keys %{$diff->{'common'}} == 1
);

# new hash, same data, same subrefs, must pass
$s_hash_2 = {%{$s_hash_1}};
ok($diff = diff($s_hash_1, $s_hash_2, 'depth' => 1) and
    keys %{$diff} == 1 and
    exists $diff->{'common'}
);
