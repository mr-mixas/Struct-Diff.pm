#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use Storable qw(dclone);
use Test::More tests => 2;

use Struct::Diff;

# recursive struct maker
sub smk($$;$);
sub smk($$;$) {
    my $depth = shift || return (rand(1) > 0.5) ? rand(65535) : int(rand(65535));
    my $width = shift;
    my $style = shift;

    my $out;
    if ((defined $style and ref $style eq 'ARRAY') or rand(1) > 0.5) {
        map { push @{$out}, smk($depth - 1, $width, $style) } 0..$width;
    } else {
        map { $out->{$_} = smk($depth - 1, $width, $style) } 0..$width;
    }
    return $out;
}

my ($diff, $s1, $s2);

srand(time);

$s1 = smk(5, 5);
$diff = diff($s1, dclone($s1));
ok(keys %{$diff} == 1 and exists $diff->{'common'});

$s1 = smk(5, 5, []);
$s2 = dclone($s1);
push @{$s2->[1]->[0]}, "added";
$diff = diff($s1, $s2);
is(pop @{$diff->{'changed'}->[0]->[1]->[0]}, "added");

