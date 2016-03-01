#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 22;

use Struct::Diff qw(diff);

my $diff;

### undefs
ok($diff = diff(undef,undef) and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    not defined $diff->{'U'}
);

ok($diff = diff(undef,0) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    not defined $diff->{'C'}->[0] and
    $diff->{'C'}->[1] == 0
);

ok($diff = diff(undef,'') and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    not defined $diff->{'C'}->[0] and
    $diff->{'C'}->[1] eq ''
);

# numbers
ok($diff = diff(0,0) and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    $diff->{'U'} == 0
);

ok($diff = diff(0,undef) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] == 0 and
    not defined $diff->{'C'}->[1]
);

ok($diff = diff(0,'') and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] == 0 and
    $diff->{'C'}->[1] eq ''
);

ok($diff = diff(1,1.0) and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    $diff->{'U'} eq 1 # deliberate eq
);

ok($diff = diff(1.0,1) and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    $diff->{'U'} eq 1 # deliberate eq
);

ok($diff = diff(1,2) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] == 1 and
    $diff->{'C'}->[1] == 2
);

ok($diff = diff('2.0',2) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] eq '2.0' and
    $diff->{'C'}->[1] == 2
);

### strings
ok($diff = diff('',undef) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] eq '' and
    not defined $diff->{'C'}->[1]
);

ok($diff = diff('',0) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] eq '' and
    $diff->{'C'}->[1] == 0
);

ok($diff = diff('a',"a") and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    $diff->{'U'} eq 'a'
);

ok($diff = diff('a','b') and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    $diff->{'C'}->[0] eq 'a' and
    $diff->{'C'}->[1] eq 'b'
);

### refs
ok($diff = diff({},{}) and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    keys %{$diff->{'U'}} == 0
);

ok($diff = diff([],[]) and
    keys %{$diff} == 1 and
    ref $diff->{'U'} eq 'ARRAY'
    and @{$diff->{'U'}} == 0
);

ok($diff = diff([],{}) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    @{$diff->{'C'}->[0]} == 0 and
    ref $diff->{'C'}->[1] eq 'HASH' and
    keys %{$diff->{'C'}->[1]} == 0
);

ok($diff = diff({},[]) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    ref $diff->{'C'}->[0] eq 'HASH' and
    keys %{$diff->{'C'}->[0]} == 0 and
    @{$diff->{'C'}->[1]} == 0
);

my $coderef1 = sub { return 0 };
ok($diff = diff($coderef1,$coderef1) and
    keys %{$diff} == 1 and
    exists $diff->{'U'} and
    $diff->{'U'} eq $coderef1
);

my $coderef2 = sub { return 1 };
ok($diff = diff($coderef1,$coderef2) and
    keys %{$diff} == 1 and
    exists $diff->{'C'} and
    @{$diff->{'C'}} == 2 and
    ref $diff->{'C'}->[0] eq 'CODE' and
    ref $diff->{'C'}->[1] eq 'CODE' and
    $diff->{'C'}->[0] eq $coderef1 and
    $diff->{'C'}->[1] eq $coderef2 and
    $diff->{'C'}->[0] ne $diff->{'C'}->[1]
);

# blessed things
use Data::Dumper;

my $blessed1 = Data::Dumper->new([]);
ok($diff = diff($blessed1,$blessed1) and
    keys %{$diff} == 1 and exists $diff->{'U'}
);

my $blessed2 = Data::Dumper->new([]);
ok($diff = diff($blessed1,$blessed2) and
    keys %{$diff} == 1 and exists $diff->{'C'}
);
