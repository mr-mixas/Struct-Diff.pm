package _common;

# common parts for Struct::Path tests

use Data::Dumper qw();
use parent qw(Exporter);

our @EXPORT_OK = qw(scmp sdump);

sub sdump($) {
    return Data::Dumper->new([shift])->Terse(1)->Sortkeys(1)->Quotekeys(0)->Indent(0)->Deepcopy(1)->Dump();
}

sub scmp($$$) { # compare structures by data
    my $got = sdump(shift);
    my $exp = sdump(shift);
    print STDERR "\nDEBUG: === " . shift . " ===\ngot: $got\nexp: $exp\n" if ($ENV{DEBUG});
    return $got eq $exp;
}

1;
