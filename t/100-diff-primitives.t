#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 24;

use Struct::Diff qw(diff);

my $d;

### undefs
ok($d = diff(undef,undef) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    not defined $d->{'U'}
);

ok($d = diff(undef,0) and
    keys %{$d} == 1 and
    exists $d->{'C'} and 
    @{$d->{'C'}} == 2 and
    not defined $d->{'C'}->[0] and
    $d->{'C'}->[1] == 0
);

ok($d = diff(undef,'') and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    not defined $d->{'C'}->[0] and
    $d->{'C'}->[1] eq ''
);

# numbers
ok($d = diff(0,0) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    $d->{'U'} == 0
);

ok($d = diff(0,undef) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] == 0 and
    not defined $d->{'C'}->[1]
);

ok($d = diff(0,'') and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] == 0 and
    $d->{'C'}->[1] eq ''
);

ok($d = diff(1,1.0) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    $d->{'U'} eq 1 # deliberate eq
);

ok($d = diff(1.0,1) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    $d->{'U'} eq 1 # deliberate eq
);

ok($d = diff(1,2) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] == 1 and
    $d->{'C'}->[1] == 2
);

ok($d = diff('2.0',2) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] eq '2.0' and
    $d->{'C'}->[1] == 2
);

### strings
ok($d = diff('',undef) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] eq '' and
    not defined $d->{'C'}->[1]
);

ok($d = diff('',0) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] eq '' and
    $d->{'C'}->[1] == 0
);

ok($d = diff('a',"a") and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    $d->{'U'} eq 'a'
);

ok($d = diff('a','b') and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] eq 'a' and
    $d->{'C'}->[1] eq 'b'
);

### refs
my ($a, $b) = (0, 0);

ok($d=diff(\$a, \$a) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    $d->{'U'} == \$a
);

ok($d=diff(\$a, \$b) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    $d->{'C'}->[0] == \$a and
    $d->{'C'}->[1] == \$b
);

ok($d = diff({},{}) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    keys %{$d->{'U'}} == 0
);

ok($d = diff([],[]) and
    keys %{$d} == 1 and
    ref $d->{'U'} eq 'ARRAY'
    and @{$d->{'U'}} == 0
);

ok($d = diff([],{}) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    @{$d->{'C'}->[0]} == 0 and
    ref $d->{'C'}->[1] eq 'HASH' and
    keys %{$d->{'C'}->[1]} == 0
);

ok($d = diff({},[]) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    ref $d->{'C'}->[0] eq 'HASH' and
    keys %{$d->{'C'}->[0]} == 0 and
    @{$d->{'C'}->[1]} == 0
);

my $coderef1 = sub { return 0 };
ok($d = diff($coderef1,$coderef1) and
    keys %{$d} == 1 and
    exists $d->{'U'} and
    $d->{'U'} eq $coderef1
);

my $coderef2 = sub { return 1 };
ok($d = diff($coderef1,$coderef2) and
    keys %{$d} == 1 and
    exists $d->{'C'} and
    @{$d->{'C'}} == 2 and
    ref $d->{'C'}->[0] eq 'CODE' and
    ref $d->{'C'}->[1] eq 'CODE' and
    $d->{'C'}->[0] eq $coderef1 and
    $d->{'C'}->[1] eq $coderef2 and
    $d->{'C'}->[0] ne $d->{'C'}->[1]
);

# blessed things
my $blessed1 = bless {}, 'SomeClassName';
ok($d = diff($blessed1,$blessed1) and
    keys %{$d} == 1 and exists $d->{'U'}
);

my $blessed2 = bless {}, 'SomeClassName';
ok($d = diff($blessed1,$blessed2) and
    keys %{$d} == 1 and exists $d->{'C'}
);
