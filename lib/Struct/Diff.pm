package Struct::Diff;

use 5.006;
use strict;
use warnings FATAL => 'all';
use base qw(Exporter);
use Carp;

BEGIN {
    our @EXPORT_OK = qw(diff dsplit strip);
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

    $diff = diff($ref1, $ref2);
    print Dumper $diff->['A']; # added
    print Dumper $diff->['C']; # changed
    print Dumper $diff->['U']; # unchanged
    print Dumper $diff->['R']; # removed
    ...

    $detailed = diff($ref1, $ref2, 'detailed' => 1);
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
    my $d = {};
    if (ref $a ne ref $b) {
        $d->{'C'} = [ $a, $b ];
    } elsif ((ref $a eq 'ARRAY') and ($a ne $b)) {
        for (my $i = 0; $i < @{$a} and $i < @{$b}; $i++) {
            my $ai = $a->[$i]; my $bi = $b->[$i];
            my $tmp = diff($ai, $bi, %opts);
            if ($opts{'detailed'}) {
                next unless (keys %{$tmp} or not $opts{'nocommon'});
                if (exists $tmp->{'D'} and @{$tmp->{'D'}} == grep { exists $_->{'U'}} @{$tmp->{'D'}}) {
                    push @{$d->{'D'}}, { 'U' => $ai };
                } else {
                    push @{$d->{'D'}}, $opts{'positions'} ? { %{$tmp}, 'position' => $i } : $tmp;
                }
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
    } elsif ((ref $a eq 'HASH') and ($a ne $b)) {
        for my $key (keys { %{$a}, %{$b} }) { # go througth united uniq keys
            if (exists $a->{$key} and exists $b->{$key}) {
                my $tmp = diff($a->{$key}, $b->{$key}, %opts);
                if ($opts{'detailed'}) {
                    next unless (keys %{$tmp} or not $opts{'nocommon'});
                    if (exists $tmp->{'D'} and keys %{$tmp->{'D'}} == grep { exists $_->{'U'} } values %{$tmp->{'D'}}) {
                        $d->{'D'}->{$key} = { 'U' => $a->{$key} };
                    } else {
                        $d->{'D'}->{$key} = $tmp;
                    }
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

=head2 dsplit

Divide diff to pseudo original structures.
    $struct = dsplit($diff);
    print Dumper $struct->{'a'}, $struct->{'b'};

=cut

sub dsplit($);
sub dsplit($) {
    my $d = shift;
    croak "Wrong metadata format" unless (ref $d eq 'HASH');
    my $s = {};

    if (exists $d->{'D'}) {
        if (ref $d->{'D'} eq 'ARRAY') {
            for my $di (@{$d->{'D'}}) {
                my ($ts) = dsplit($di);
                push @{$s->{'a'}}, $ts->{'a'} if (exists $ts->{'a'});
                push @{$s->{'b'}}, $ts->{'b'} if (exists $ts->{'b'});
            }
        } elsif (ref $d->{'D'} eq 'HASH') {
            for my $key (keys %{$d->{'D'}}) {
                my ($ts) = dsplit($d->{'D'}->{$key});
                $s->{'a'}->{$key} = $ts->{'a'} if (exists $ts->{'a'});
                $s->{'b'}->{$key} = $ts->{'b'} if (exists $ts->{'b'});
            }
        }
    }

    if (exists $d->{'U'}) {
        if (ref $d->{'U'} eq 'ARRAY') {
            push @{$s->{'a'}}, @{$d->{'U'}};
            push @{$s->{'b'}}, @{$d->{'U'}};
        } elsif (ref $d->{'U'} eq 'HASH') {
            $s->{'a'} = defined $s->{'a'} ? { %{$s->{'a'}}, %{$d->{'U'}} } : { %{$d->{'U'}} };
            $s->{'b'} = defined $s->{'b'} ? { %{$s->{'b'}}, %{$d->{'U'}} } : { %{$d->{'U'}} };
        } else {
            croak "Duplicates with different status" if (defined $s->{'a'} or defined $s->{'b'});
            $s->{'a'} = $s->{'b'} = $d->{'U'};
        }
    }

    if (exists $d->{'C'}) {
        if (ref $d->{'C'} eq 'ARRAY' and ref $d->{'C'}->[0] eq 'ARRAY' and ref $d->{'C'}->[1] eq 'ARRAY') {
            for my $i (@{$d->{'C'}}) {
                croak "Incorrect format for changed array element" if (@{$i} < 2 or @{$i} > 3);
                if (@{$i} == 2) {
                    carp "Position for changed array item not specified, would be added to the end";
                    push @{$s->{'a'}}, $i->[0];
                    push @{$s->{'b'}}, $i->[1];
                } else {
                    push @{$s->{'a'}}, $i->[0], splice(@{$s->{'a'}}, $i->[2]);
                    push @{$s->{'b'}}, $i->[1], splice(@{$s->{'b'}}, $i->[2]);
                }
            }
        } elsif (ref $d->{'C'} eq 'HASH') {
            for my $key (keys %{$d->{'C'}}) {
                croak "Incorrect format for changed hash element" if (@{$d->{'C'}->{$key}} != 2);
                $s->{'a'}->{$key} = $d->{'C'}->{$key}->[0];
                $s->{'b'}->{$key} = $d->{'C'}->{$key}->[1];
            }
        } else {
            croak "Incorrect amount of changed elements" if (@{$d->{'C'}} != 2);
            croak "Duplicates with different status" if (defined $s->{'a'} or defined $s->{'b'});
            $s->{'a'} = $d->{'C'}->[0];
            $s->{'b'} = $d->{'C'}->[1];
        }
    }

    if (exists $d->{'A'}) {
        if (ref $d->{'A'} eq 'ARRAY') {
            push @{$s->{'b'}}, @{$d->{'A'}};
        } elsif (ref $d->{'A'} eq 'HASH') {
            $s->{'b'} = defined $s->{'b'} ? { %{$s->{'b'}}, %{$d->{'A'}} } : { %{$d->{'A'}} };
        } else {
            $s->{'b'} = $d->{'A'};
        }
    }

    if (exists $d->{'R'}) {
        if (ref $d->{'R'} eq 'ARRAY') {
            push @{$s->{'a'}}, @{$d->{'R'}};
        } elsif (ref $d->{'R'} eq 'HASH') {
            $s->{'a'} = defined $s->{'a'} ? { %{$s->{'a'}}, %{$d->{'R'}} } : { %{$d->{'R'}} };
        } else {
            $s->{'a'} = $d->{'R'};
        }
    }

    return $s;
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
