#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use lib ('../lib', '.');

use Benchmark qw(cmpthese);
use JSON;

require Struct::Diff;
require _StructDiff095;

sub slurp {
    my $file = shift;

    open(my $fh, '<', $file) or die "Failed to open file '$file' ($!)", 2;
    my $data = do { local $/; <$fh> };
    close($fh);

    return JSON->new->decode($data);
}

my $VER = $Struct::Diff::VERSION;

eval { require Data::Diff };
print STDERR "Unable to load Data::Diff, skip it\n" if ($@);

eval { require Data::Difference };
print STDERR "Unable to load Data::Difference, skip it\n" if ($@);

for (qw(
        widespread_deep_changes_hash_of_hashes
        widespread_deep_changes_list_of_lists
        single_deep_change_hash_of_hashes
        single_deep_change_list_of_lists
)) {
    print "\n===== $_ =====\n";

    my $A = slurp("$_.a.json");
    my $B = slurp("$_.b.json");
    my $rivals = {};

    # control previous
    $rivals->{"Struct::Diff 0.95"} = sub { _StructDiff095::diff($A, $B) };

    # current
    $rivals->{"Struct::Diff $VER"} = sub { Struct::Diff::diff($A, $B) };

    # others if available
    $rivals->{"Data::Diff"} = sub { Data::Diff::Diff($A, $B) }
        if (defined &Data::Diff::Diff);
    $rivals->{"Data::Difference"} = sub { Data::Difference::data_diff($A, $B) }
        if (defined &Data::Difference::data_diff);

    cmpthese (-3, $rivals);
}

