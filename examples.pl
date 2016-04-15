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
        'a' => [ 2, 3, 4, 5, 6, 7 ],
        'b' => [ 2, 3, 9, 5, 6, 7 ],
        'desc' => "Arrays, one lement changed",
        'opts' => {},
    },
    {
        'a' => [ 2, 3, 4, 5, 6, 7, 8 ],
        'b' => [ 2, 3, 4, 5, 6, 7 ],
        'desc' => "Arrays, one element removed",
        'opts' => {},
    },
    {
        'a' => [ 2, 3, 4, 5, 6, 7, 8 ],
        'b' => [ 2, 3, 4, 5, 6, 7 ],
        'desc' => "Same, without common",
        'opts' => { noU => 1 },
    },
    {
        'a' => { x => { y => { z => 'v' }}},
        'b' => { x => { y => { z => 'cv' }}},
        'desc' => "Hashes, deep-down val changed",
        'opts' => {},
    },
    {
        'a' => { x => [ 7, { y => 4 } ] },
        'b' => { x => [ 7, { y => 9 } ] },
        'desc' => "Mixed (ARRAYS/HASHES) structure",
        'opts' => {},
    },
    {
        'a' => { x => [ 7, { y => 4 } ] },
        'b' => { x => [ 7, { y => 9 } ] },
        'desc' => "Same, but without common items and old values",
        'opts' => { noU => 1, noO => 1 },
    },
);

print "\n";

for my $e (@examples) {
    my $d = diff($e->{a}, $e->{b}, %{$e->{opts}});
    print "####### $e->{desc} #######\n";
    print Data::Dumper->Dump([$e->{a}], ["a"]), "\n";
    print Data::Dumper->Dump([$e->{b}], ["b"]), "\n";
    print Data::Dumper->Dump([$e->{opts}], ["*opts"]), "\n";
    {
#        local $Data::Dumper::Indent = 2;
        print Data::Dumper->Dump([$d], ["diff"]), "\n\n";
    }
}
