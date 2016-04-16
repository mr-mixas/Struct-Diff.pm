#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use lib 'lib';

use Data::Dumper;
use Struct::Diff qw(diff dselect dsplit patch);

$Data::Dumper::Indent = 0;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys = 1;

my @examples = (
    {
        'a' => "Some old value",
        'b' => "Some new value",
        'desc' => "Scalars",
        'opts_diff' => {},
    },
    {
        'a' => [ 2, 3, 4, 5, 6, 7 ],
        'b' => [ 2, 3, 9, 5, 6, 7 ],
        'desc' => "Arrays, one lement changed",
        'opts_diff' => {},
    },
    {
        'a' => [ 2, 3, 4, 5, 6, 7, 8 ],
        'b' => [ 2, 3, 4, 5, 6, 7 ],
        'desc' => "Arrays, one element removed",
        'opts_diff' => {},
        'opts_dselect' => { states => { R => 1 }, fromD => [] },
    },
    {
        'a' => [ 2, 3, 4, 5, 6, 7, 8 ],
        'b' => [ 2, 3, 4, 5, 6, 7 ],
        'desc' => "Same, without common",
        'opts_diff' => { noU => 1 },
    },
    {
        'a' => { x => { y => { z => 'v' }}},
        'b' => { x => { y => { z => 'cv' }}},
        'desc' => "Hashes, deep-down val changed",
        'opts_diff' => {},
    },
    {
        'a' => { x => [ 7, { y => 4 } ] },
        'b' => { x => [ 7, { y => 9 } ], z => 33 },
        'desc' => "Mixed (ARRAYS/HASHES) structure",
        'opts_diff' => {},
    },
    {
        'a' => { x => [ 7, { y => 4 } ] },
        'b' => { x => [ 7, { y => 9 } ], z => 33 },
        'desc' => "Same, but without common items and old values",
        'opts_diff' => { noU => 1, noO => 1 },
        'opts_dselect' => { fromD => [ 'z' ]},
        'run_dsplit' => 1,
    },
);

print "\n";

for my $e (@examples) {
    my $d = diff($e->{a}, $e->{b}, %{$e->{opts_diff}});
    print "####### $e->{desc} #######\n";
    print Data::Dumper->Dump([$e->{a}], ["a"]), "\n";
    print Data::Dumper->Dump([$e->{b}], ["b"]), "\n\n";

    print Data::Dumper->Dump([$e->{opts_diff}], ["*opts_diff"]), "\n";
    {
#        local $Data::Dumper::Indent = 2;
        print Data::Dumper->Dump([$d], ["diff"]), "\n\n";
    }
    if ($e->{opts_dselect}) {
        my @s = dselect($d, %{$e->{opts_dselect}});
        print Data::Dumper->Dump([$e->{opts_dselect}], ["*opts_dselect"]), "\n";
        print Data::Dumper->Dump([\@s], ["dselect"]), "\n\n";
    }
    if ($e->{run_dsplit}) {
        my $s = dsplit($d);
        for my $k ('a', 'b') {
            if (exists $s->{$k}) {
                print Data::Dumper->Dump([$s->{$k}], ["dsplit->{$k}"]), "\n\n";
            } else {
                print "\$dsplit->{$k} not exists\n";
            }
        }
    }
}
