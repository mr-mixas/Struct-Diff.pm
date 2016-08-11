#!perl -T

use strict;
use warnings;
use Test::More tests => 26;

use Struct::Diff qw(diff);

my $d;

### undefs
ok($d = diff(undef, undef) and
    keys %{$d} == 1 and exists $d->{'U'} and not defined $d->{'U'}
);

ok($d = diff(undef, 0) and
    keys %{$d} == 2 and
        exists $d->{'O'} and not defined $d->{'O'} and
        exists $d->{'N'} and $d->{'N'} == 0
);

ok($d = diff(undef, '') and
    keys %{$d} == 2 and
        exists $d->{'O'} and not defined $d->{'O'} and
        exists $d->{'N'} and $d->{'N'} eq ''
);

### numbers
ok($d = diff(0, 0) and
    keys %{$d} == 1 and exists $d->{'U'} and $d->{'U'} == 0
);

ok($d = diff(0, undef) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} == 0 and
        exists $d->{'N'} and not defined $d->{'N'}
);

ok($d = diff(0, '') and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} == 0 and
        exists $d->{'N'} and $d->{'N'} eq ''
);

ok($d = diff(1, 1.0) and
    keys %{$d} == 1 and exists $d->{'U'} and $d->{'U'} eq 1 # deliberate eq
);

ok($d = diff(1.0, 1) and
    keys %{$d} == 1 and exists $d->{'U'} and $d->{'U'} eq 1 # deliberate eq
);

ok($d = diff(1, 2) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} == 1 and
        exists $d->{'N'} and $d->{'N'} == 2
);

ok($d = diff('2.0', 2) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} eq '2.0' and
        exists $d->{'N'} and $d->{'N'} == 2
);

### strings
ok($d = diff('', undef) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} eq '' and
        exists $d->{'N'} and not defined $d->{'N'}
);

ok($d = diff('', 0) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} eq '' and
        exists $d->{'N'} and $d->{'N'} == 0
);

ok($d = diff('a', "a") and
    keys %{$d} == 1 and exists $d->{'U'} and $d->{'U'} eq 'a'
);

ok($d = diff('a', 'b') and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} eq 'a' and
        exists $d->{'N'} and $d->{'N'} eq 'b'
);

### refs
my ($a, $b) = (0, 0);

ok($d=diff(\$a, \$a) and
    keys %{$d} == 1 and exists $d->{'U'} and $d->{'U'} == \$a
);

ok($d=diff($a, \$a) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} == $a and
        exists $d->{'N'} and $d->{'N'} == \$a
);

ok($d=diff($a, \$a, 'noO' => 1, 'noN' => 1) and
    keys %{$d} == 0
);

ok($d=diff(\$a, \$b) and
    keys %{$d} == 2 and
        exists $d->{'O'} and $d->{'O'} == \$a and
        exists $d->{'N'} and $d->{'N'} == \$b
);

ok($d = diff({}, {}) and
    keys %{$d} == 1 and exists $d->{'U'} and keys %{$d->{'U'}} == 0
);

ok($d = diff([], []) and
    keys %{$d} == 1 and ref $d->{'U'} eq 'ARRAY' and @{$d->{'U'}} == 0
);

ok($d = diff([], {}) and
    keys %{$d} == 2 and
        exists $d->{'O'} and ref $d->{'O'} eq 'ARRAY' and @{$d->{'O'}} == 0 and
        exists $d->{'N'} and ref $d->{'N'} eq 'HASH' and keys %{$d->{'N'}} == 0
);

ok($d = diff({}, []) and
    keys %{$d} == 2 and
        exists $d->{'O'} and ref $d->{'O'} eq 'HASH' and keys %{$d->{'O'}} == 0 and
        exists $d->{'N'} and ref $d->{'N'} eq 'ARRAY' and @{$d->{'N'}} == 0
);

my $coderef1 = sub { return 0 };
ok($d = diff($coderef1, $coderef1) and
    keys %{$d} == 1 and exists $d->{'U'} and $d->{'U'} eq $coderef1
);

my $coderef2 = sub { return 1 };
ok($d = diff($coderef1, $coderef2) and
    keys %{$d} == 2 and
        exists $d->{'O'} and
            ref $d->{'O'} eq 'CODE' and $d->{'O'} eq $coderef1 and
        exists $d->{'N'} and
            ref $d->{'N'} eq 'CODE' and $d->{'N'} eq $coderef2 and
        $d->{'O'} ne $d->{'N'}
);

### blessed things
my $blessed1 = bless {}, 'SomeClassName';
ok($d = diff($blessed1, $blessed1) and
    keys %{$d} == 1 and
        exists $d->{'U'} and
            ref $d->{'U'} eq 'SomeClassName' and $d->{'U'} eq $blessed1
);

my $blessed2 = bless {}, 'SomeClassName';
ok($d = diff($blessed1, $blessed2) and
    keys %{$d} == 2 and
        exists $d->{'O'} and
            ref $d->{'O'} eq 'SomeClassName' and $d->{'O'} eq $blessed1 and
        exists $d->{'N'} and
            ref $d->{'N'} eq 'SomeClassName' and $d->{'N'} eq $blessed2 and
        $d->{'O'} ne $d->{'N'}
);
