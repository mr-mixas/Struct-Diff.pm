package Struct::Diff;

use 5.006;
use strict;
use warnings FATAL => 'all';
use base qw(Exporter);

BEGIN {
    our @EXPORT_OK = qw(diff strip);
}

=head1 NAME

Struct::Diff - Recursive diff tools for nested perl structures

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    use Data::Dumper;
    use Struct::Diff qw(diff);

    my $diff = diff($ref1, $ref2);
    print Dumper $diff->['A']; # added
    print Dumper $diff->['C']; # changed
    print Dumper $diff->['U']; # unchanged
    print Dumper $diff->['R']; # removed
    ...

    my $detailed = diff($ref1, $ref2, 'detailed' => 1);
    print Dumper $detailed;

=head1 EXPORT

Nothing exports by default

=head1 SUBROUTINES

=head2 diff

Returns HASH reference to diff between two passed references. Diff consists of linked parts of passed
structures, be aware of it changing diff.
    $diff = diff($ref1, $ref2, %opts);

=head3 Available options

=over 4

=item depth

Don't descend to structs deeper than specified level. Not defined (disabled) by default.

=item detailed

Explicit diff - each struct layer anticipated by metadata. This approach allows to trace exact changed elements
in substructures. When disabled (by default is) metadata only on top of diff - easy way to know which elements of
passed structures are changed and work with them.

=item nocommon

Hide unchanged parts.

=item positions

Show index for changed array items.

=item separate-changed

Split changed items in arrays to "added" and "removed"

=back

=cut

sub diff($$;@);
sub diff($$;@) {
    my ($a, $b, %opts) = @_;
    $opts{'depth'}-- if (exists $opts{'depth'});
    my $d = {};
    if (ref $a ne ref $b) {
        $d->{'C'} = [ $a, $b ];
    } elsif ((ref $a eq 'ARRAY') and ($a ne $b) and (not exists $opts{'depth'} or $opts{'depth'} >= 0)) {
        for (my $i = 0; $i < @{$a} and $i < @{$b}; $i++) {
            my $ai = $a->[$i]; my $bi = $b->[$i];
            my $tmp = diff($ai, $bi, %opts);
            if ($opts{'detailed'}) {
                push @{$d->{'D'}}, $opts{'positions'} ? { %{$tmp}, 'position' => $i } : $tmp
                    if (keys %{$tmp} or not $opts{'nocommon'});
            } else {
                if (exists $tmp->{'A'} or exists $tmp->{'C'} or exists $tmp->{'R'}) {
                    if ($opts{'separate-changed'}) {
                        push @{$d->{'R'}}, $ai;
                        push @{$d->{'A'}}, $bi;
                    } else {
                        push @{$d->{'C'}}, $opts{'positions'} ? [ $ai, $bi, $i ] : [ $ai, $bi ];
                    }
                } else {
                    push @{$d->{'U'}}, $ai unless ($opts{'nocommon'});
                }
            }
        }
        if ($opts{'detailed'}) {
            map { push @{$d->{'D'}}, { 'R' => $_ } } @{$a}[@{$b}..$#{$a}] if (@{$a} > @{$b});
            map { push @{$d->{'D'}}, { 'A' => $_ } } @{$b}[@{$a}..$#{$b}] if (@{$a} < @{$b});
        } else {
            push @{$d->{'R'}}, @{$a}[@{$b}..$#{$a}] if (@{$a} > @{$b});
            push @{$d->{'A'}}, @{$b}[@{$a}..$#{$b}] if (@{$a} < @{$b});
        }
    } elsif ((ref $a eq 'HASH') and ($a ne $b) and (not exists $opts{'depth'} or $opts{'depth'} >= 0)) {
        for my $key (keys { %{$a}, %{$b} }) { # go througth united uniq keys
            if (exists $a->{$key} and exists $b->{$key}) {
                my $tmp = diff($a->{$key}, $b->{$key}, %opts);
                if ($opts{'detailed'}) {
                    $d->{'D'}->{$key} = $tmp unless ($opts{'nocommon'} and not keys %{$tmp});
                } else {
                    if (exists $tmp->{'A'} or exists $tmp->{'C'} or exists $tmp->{'R'}) {
                        if ($opts{'separate-changed'}) {
                            $d->{'R'}->{$key} = $a->{$key};
                            $d->{'A'}->{$key} = $b->{$key};
                        } else {
                            push @{$d->{'C'}->{$key}}, $a->{$key}, $b->{$key};
                        }
                    } else {
                        $d->{'U'}->{$key} = $a->{$key} unless ($opts{'nocommon'});
                    }
                }
            } elsif (exists $a->{$key}) {
                if ($opts{'detailed'}) {
                    $d->{'D'}->{$key} = { 'R' => $a->{$key} };
                } else {
                    $d->{'R'}->{$key} = $a->{$key};
                }
            } else {
                if ($opts{'detailed'}) {
                    $d->{'D'}->{$key} = { 'A' => $b->{$key} };
                } else {
                    $d->{'A'}->{$key} = $b->{$key};
                }
            }
        }
    } else { # treat others as scalars
        unless ((not defined $a and not defined $b) or ((defined $a and defined $b) and ($a eq $b))) {
            if ($opts{'separate-changed'}) {
                $d->{'R'} = $a;
                $d->{'A'} = $b;
            } else {
                $d->{'C'} = [ $a, $b ];
            }
        }
    }
    $d->{'U'} = $a unless (keys %{$d} or $opts{'nocommon'}); # if passed srtucts are empty
    return $d;
}

=head2 strip

Remove common parts from two passed refs (diff inside-out)
    strip($ref1, $ref2);

=cut

sub strip($$);
sub strip($$) {
    my ($a, $b) = @_;
    my $d;
    if (ref $a ne ref $b) {
        $d->{'C'} = [ $a, $b ];
    } elsif (ref $a eq 'ARRAY') {
        my $fa = [@{$a}]; my $sa = [ @{$b} ]; # copy to new arrays to prevent original arrays corruption
        for (my $i = 0; @{$fa} and @{$sa}; $i++) {
            my $ai = shift(@{$fa}); my $bi = shift(@{$sa});
            my $tmp = strip($ai, $bi);
            if (exists $tmp->{'A'} or exists $tmp->{'C'} or exists $tmp->{'R'}) {
                push @{$d->{'C'}}, [ $ai, $bi ];
            } else {
                splice @{$a}, $i, 1;
                splice @{$b}, $i, 1;
                $i--;
            }
        }
        push @{$d->{'R'}}, @{$a} if (@{$a});
        push @{$d->{'A'}}, @{$b} if (@{$b});
    } elsif (ref $a eq 'HASH') {
        for my $key (keys { map { $_, 1 } (keys %{$a}, keys %{$b}) }) { # go througth united uniq keys
            if (exists $a->{$key} and exists $b->{$key}) {
                my $tmp = strip($a->{$key}, $b->{$key});
                if (exists $tmp->{'A'} or exists $tmp->{'C'} or exists $tmp->{'R'}) {
                    push @{$d->{'C'}->{$key}}, $a->{$key}, $b->{$key};
                } else {
                    delete $a->{$key};
                    delete $b->{$key};
                }
            } elsif (exists $a->{$key}) {
                $d->{'R'}->{$key} = $a->{$key};
            } else {
                $d->{'A'}->{$key} = $b->{$key};
            }
        }
    } else { # treat others as scalars
        unless ((not defined $a and not defined $b) or ((defined $a and defined $b) and ($a eq $b))) {
            $d->{'C'} = [ $a, $b ];
        }
    }
    return $d;
}

=head1 AUTHOR

Michael Samoglyadov, C<< <mixas at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-struct-diff at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff>. I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Struct::Diff

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Struct-Diff>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Struct-Diff>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Struct-Diff>

=item * Search CPAN

L<http://search.cpan.org/dist/Struct-Diff/>

=back


=head1 SEE ALSO

L<Data::Diff>

L<Array::Diff>, L<Array::Compare>, L<Algorithm::Diff>, L<Hash::Diff>, L<Test::Struct>, L<Struct::Compare>

=head1 LICENSE AND COPYRIGHT

Copyright 2015-2016 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1; # End of Struct::Diff
