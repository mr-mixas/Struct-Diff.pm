package _common;

# common parts for Struct::Path tests

use strict;
use warnings FATAL => 'all';
use parent qw(Exporter);

use Clone qw(clone);
use Data::Dumper qw();
use Struct::Diff qw(diff patch valid_diff);
use Test::More 0.94;

our @EXPORT = qw(
    run_batch_tests
    scmp
    sdump
);

my $EXP_KEYS;
if ($ENV{EXPORT_TESTS_DIR}) {

    $ENV{EXPORT_TESTS_DIR} =~ /(.*)/;
    $ENV{EXPORT_TESTS_DIR} = $1; # untaint

    $EXP_KEYS = { map { $_ => 1 } qw(a b diff opts patched) };

    require JSON;
}

sub run_batch_test_diff {
    my $t = shift;

    return if ($t->{skip_diff});

    my $st = clone($t);

    my $diff = eval { diff($st->{a}, $st->{b}, %{$st->{opts}}) };
    if ($@) {
        fail("Diff: $@");
        return;
    }

    subtest "Diff " . $t->{name} => sub {
        plan tests => 3;

        is_deeply($diff, $st->{diff}, "Diff: $st->{name}") ||
            diag scmp($diff, $st->{diff});

        is_deeply($st->{a}, $t->{a}, "A mangled: $st->{name}") ||
            diag scmp($st->{a}, $t->{a});
        is_deeply($st->{b}, $t->{b}, "B mangled: $st->{name}") ||
            diag scmp($st->{b}, $t->{b});
    };
}

sub run_batch_test_patch {
    my $t = shift;

    return if ($t->{skip_patch});

    my $expected = exists $t->{patched} ? $t->{patched} : $t->{b};
    my $patch = clone($t->{diff});
    my $target = clone($t->{a});

    eval { patch($target, $patch) };
    if ($@) {
        if ($t->{error_patch}) {
            pass("expected error")
        } else {
            fail("Patch: $@");
        }

        return;
    }

    subtest "Patch " . $t->{name} => sub {
        plan tests => 2;

        is_deeply($target, $expected, "Patch: $t->{name}") ||
            diag scmp($target, $expected);

        is_deeply($t->{diff}, $patch, "Patch: diff mangled: $t->{name}") ||
            diag scmp($t->{diff}, $patch);
    };
}

sub run_batch_test_valid {
    my $t = shift;

    return if ($t->{skip_valid});

    my $diff = clone($t->{diff});

    subtest "Valid " . $t->{name} => sub {
        plan tests => 2;

        ok(valid_diff($diff));

        is_deeply($diff, $t->{diff}, "Valid: diff mangled: $t->{name}") ||
            diag scmp($diff, $t->{diff});
    };
}

sub run_batch_tests {
    local $Test::Builder::Level = $Test::Builder::Level + 2;

    for my $t (@_) {
        # export tests to JSON
        if ($EXP_KEYS and (!exists $t->{to_json} or $t->{to_json})) {
            die "Export dir doesn't exist" unless (-d $ENV{EXPORT_TESTS_DIR});

            my $data = clone($t);
            map { delete $data->{$_} unless ($EXP_KEYS->{$_}) } keys %{$data};

            my $file = "$ENV{EXPORT_TESTS_DIR}/$t->{name}.json";
            open(my $fh, '>', $file) or die "Failed to open file '$file' ($!)";
            print $fh JSON->new->pretty(1)->canonical(1)->encode($data);
            close($fh);
        }

        # run tests
        run_batch_test_diff($t);
        run_batch_test_patch($t);
        run_batch_test_valid($t);
    }
}

sub scmp($$) {
    return "GOT: " . sdump(shift) . ";\nEXP: " . sdump(shift) . ";";
}

sub sdump($) {
    return Data::Dumper->new([shift])->Terse(1)->Sortkeys(1)->Quotekeys(0)->Indent(0)->Deepcopy(1)->Dump();
}

1;

