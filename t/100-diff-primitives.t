#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 17;

use Struct::Diff qw(diff);

my $diff;

### undefs
ok($diff = diff(undef,undef) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    not defined $diff->{'common'}
);

ok($diff = diff(undef,0) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    not defined $diff->{'changed'}->[0] and
    $diff->{'changed'}->[1] == 0
);

ok($diff = diff(undef,'') and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    not defined $diff->{'changed'}->[0] and
    $diff->{'changed'}->[1] eq ''
);

# numbers
ok($diff = diff(0,0) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    $diff->{'common'} == 0
);

ok($diff = diff(0,undef) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] == 0 and
    not defined $diff->{'changed'}->[1]
);

ok($diff = diff(0,'') and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] == 0 and
    $diff->{'changed'}->[1] eq ''
);

ok($diff = diff(1,1.0) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    $diff->{'common'} eq 1 # deliberate eq
);

ok($diff = diff(1.0,1) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    $diff->{'common'} eq 1 # deliberate eq
);

ok($diff = diff(1,2) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] == 1 and
    $diff->{'changed'}->[1] == 2
);

ok($diff = diff('2.0',2) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] eq '2.0' and
    $diff->{'changed'}->[1] == 2
);

### strings
ok($diff = diff('',undef) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] eq '' and
    not defined $diff->{'changed'}->[1]
);

ok($diff = diff('',0) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] eq '' and
    $diff->{'changed'}->[1] == 0
);

ok($diff = diff('a',"a") and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    $diff->{'common'} eq 'a'
);

ok($diff = diff('a','b') and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    @{$diff->{'changed'}} == 2 and
    $diff->{'changed'}->[0] eq 'a' and
    $diff->{'changed'}->[1] eq 'b'
);

### refs
ok($diff = diff({},{}) and
    keys %{$diff} == 1 and
    exists $diff->{'common'} and
    keys %{$diff->{'common'}} == 0
);

ok($diff = diff([],[]) and
    keys %{$diff} == 1 and
    ref $diff->{'common'} eq 'ARRAY'
    and @{$diff->{'common'}} == 0
);

ok($diff = diff([],{}) and
    keys %{$diff} == 1 and
    exists $diff->{'changed'} and
    ref $diff->{'changed'}->[0] eq 'ARRAY' and
    @{$diff->{'changed'}->[0]} == 0 and
    ref $diff->{'changed'}->[1] eq 'HASH' and
    keys %{$diff->{'changed'}->[1]} == 0
);
