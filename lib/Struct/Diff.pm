package Struct::Diff;

use 5.006;
use strict;
use warnings FATAL => 'all';
use base qw(Exporter);
use Carp;

BEGIN {
    our @EXPORT_OK = qw(diff dselect dsplit patch);
}

sub _validate_meta($) {
    my $d = shift;
    croak "Unsupported diff struct passed" if (ref $d ne 'HASH');
    croak "Item can't have more than one state at a time"
        if (keys %{$d} and not (grep { exists $d->{$_} } qw(A C D R U)) == 1);
    if (exists $d->{'C'}) {
        croak "Value for 'C' state must be a list" unless (ref $d->{'C'} eq 'ARRAY');
        if (@{$d->{'C'}} == 2) {
            croak "Array's changed item must have third 'C' status (it's index)"
                if (ref $d->{'C'}->[0] eq 'ARRAY' and ref $d->{'C'}->[1] eq 'ARRAY');
        } elsif (@{$d->{'C'}} == 3) {
            croak "Only array's changed element may have third 'C' status"
                unless (ref $d->{'C'}->[0] eq 'ARRAY' and ref $d->{'C'}->[1] eq 'ARRAY');
        } else {
            croak "Value for 'C' state must have two or three list items";
        }
    }
    if (exists $d->{'D'}) {
        croak "Value for 'D' status must be hash or array"
            unless (ref $d->{'D'} eq 'HASH' or ref $d->{'D'} eq 'ARRAY');
    }
    return 1;
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
    print Dumper $diff;

=head1 EXPORT

Nothing exports by default

=head1 SUBROUTINES

=head2 diff

Returns HASH reference to diff between two passed structures. Each struct layer anticipated by metadata. Be aware when
changing diff: some of it's substructures are links to original structures.
    $diff = diff($ref1, $ref2, %opts);

=head3 Diff's states

Diff's keys shows status of each item from passed structures.

=over 4

=item A

'A' stands for 'added' (exists only in second passed structure), it's value - added item.

=item D

'D' means 'different' status and shows that underneath struct have subdiff.

=item N

'N' is a new value for changed item

=item O

Alike 'N', 'O' is a changed item's old value

=item R

'R' similar for 'A', but for removed items.

=item U

'U' represent 'unchanged' items -- common for both structures.

=back

=head3 Available options

=over 4

=item noU

Hide unchanged parts.

=item separate-changed

Split changed items in arrays to "added" and "removed"

=back

=cut

sub diff($$;@);
sub diff($$;@) {
    my ($a, $b, %opts) = @_;
    my $d = {};

    if (ref $a ne ref $b) {
        $d->{'O'} = $a;
        $d->{'N'} = $b;
    } elsif ((ref $a eq 'ARRAY') and ($a ne $b)) {
        my $hidden;
        for (my $i = 0; $i < @{$a} and $i < @{$b}; $i++) {
            my $tmp = diff($a->[$i], $b->[$i], %opts);
            if (keys %{$tmp}) {
                $tmp->{'I'} = $i if ($hidden or (exists $tmp->{'C'} and $opts{'noU'}));
                push @{$d->{'D'}}, $tmp;
            } else {
                $hidden = 1;
            }
        }
        map { push @{$d->{'D'}}, { 'R' => $_ } } @{$a}[@{$b}..$#{$a}] if (@{$a} > @{$b});
        map { push @{$d->{'D'}}, { 'A' => $_ } } @{$b}[@{$a}..$#{$b}] if (@{$a} < @{$b});

        my $s = { map { $_, 1 } map { keys %{$_} } exists $d->{'D'} ? @{$d->{'D'}} : { 'U' => 1 } };
        delete $s->{'I'}; # ignored -- not a status

        if (keys %{$s} < 2 and not $hidden) { # all have one state - drop D and return native state
            my ($n) = (keys(%{$s}))[0];
            map { $_ = $_->{$n} } @{$d->{'D'}};
            $d->{$n} = delete $d->{'D'};
        }

    } elsif ((ref $a eq 'HASH') and ($a ne $b)) {
        my $hidden;
        for my $key (keys { %{$a}, %{$b} }) { # go througth united uniq keys
            if (exists $a->{$key} and exists $b->{$key}) {
                my $tmp = diff($a->{$key}, $b->{$key}, %opts);
                $hidden = 1 unless (keys %{$tmp});
                while (my ($s, $v) = each(%{$tmp})) {
                    if ($s eq 'D') {
                        $d->{'D'}->{$key} = $tmp;
                    } else {
                        $d->{$s}->{$key} = $v;
                    }
                }
            } elsif (exists $a->{$key}) {
                $d->{'R'}->{$key} = $a->{$key};
            } else {
                $d->{'A'}->{$key} = $b->{$key};
            }
        }
        if (keys %{$d} > 1 or $hidden) {
            for my $s (keys %{$d}) {
                next if ($s eq 'D');
                map { $d->{'D'}->{$_}->{$s} = delete $d->{$s}->{$_} } keys %{$d->{$s}};
                delete $d->{$s} unless ($s eq 'D');
            }
        }
    } else { # treat others as scalars
        unless ((not defined $a and not defined $b) or ((defined $a and defined $b) and ($a eq $b))) {
            if ($opts{'separate-changed'}) {
                $d->{'R'} = $a;
                $d->{'A'} = $b;
            } else {
                $d->{'O'} = $a;
                $d->{'N'} = $b;
            }
        }
    }
    $d->{'U'} = $a unless (keys %{$d} or $opts{'noU'}); # if passed srtucts are empty
    return $d;
}

=head2 dselect

Returns items with desired status from diff
    @items = dselect($diff, states => { 'A' => 1, 'U' => 1 }, 'from' => [ 'a', 'b', 'c' ]) # hashes
    @items = dselect($diff, states => { 'D' => 1, 'C' => 1 }, 'from' => [ 0, 1, 3, 5, 9 ]) # arrays

=head3 Available options

=over 4

=item from

Expects list of positions (indexes for arrays and keys for hashes). All items with specified states will be returned
if opt not defined

=item states

Expects hash with desired states as keys with values in some true value. Items with all states will be returned if
opt not defined

=back

=cut

sub dselect(@) {
    my ($d, %opts) = @_;
    _validate_meta($d);
    my @out;

    while (my($k, $v) = each %{$d}) {
        if ($k eq 'D') {
            if (ref $v eq 'ARRAY') {
                for my $i ($opts{'from'} ? @{$opts{'from'}} : 0..$#{$v}) {
                    croak "Requested index $i not in diff's array range" unless ($i >= 0 and $i < @{$v});
                    for (keys %{$v->[$i]}) {
                        next if ($opts{'states'} and not $opts{'states'}{$_});
                        push @out, $v->[$i];
                        last;
                    }
                }
            } elsif (ref $v eq 'HASH') {
                for my $i ($opts{'from'} ? @{$opts{'from'}} : keys %{$v}) {
                    next unless (exists $v->{$i});
                    for (keys %{$v->{$i}}) {
                        next if ($opts{'states'} and not $opts{'states'}{$_});
                        push @out, { $i => $v->{$i} };
                        last;
                    }
                }
            }
        } else {
            next if ($opts{'states'} and not $opts{'states'}{$k});
            push @out, { $k => $v };
        }
    }

    return @out;
}

=head2 dsplit

Divide diff to pseudo original structures.
    $struct = dsplit($diff);
    print Dumper $struct->{'a'}, $struct->{'b'};

=cut

sub dsplit($);
sub dsplit($) {
    my $d = shift;
    _validate_meta($d);
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
                croak "Incorrect format for changed array element" unless (@{$i} == 3);
                push @{$s->{'a'}}, $i->[0], splice(@{$s->{'a'}}, $i->[2]);
                push @{$s->{'b'}}, $i->[1], splice(@{$s->{'b'}}, $i->[2]);
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

=head2 patch

Apply diff to reference.
    patch($ref, $diff);

=cut

sub patch($$);
sub patch($$) {
    my ($s, $d) = @_;
    _validate_meta($d);

    if (exists $d->{'C'}) {
        unless (ref $d->{'C'}->[1]) {
            ${$s} = $d->{'C'}->[1];
        }
    }

    if (exists $d->{'D'}) {
        if (ref $d->{'D'} eq 'ARRAY') {
            for my $i (0..$#{$d->{'D'}}) {
                next if (exists $d->{'D'}->[$i]->{'U'});
                if (exists $d->{'D'}->[$i]->{'D'} or exists $d->{'D'}->[$i]->{'C'}) {
                    patch(ref $s->[$i] ? $s->[$i] : \$s->[$i], $d->{'D'}->[$i]);
                    next;
                }
                if (exists $d->{'D'}->[$i]->{'A'}) {
                    push @{$s}, $d->{'D'}->[$i]->{'A'};
                    next;
                }
                pop @{$s} if (exists $d->{'D'}->[$i]->{'R'});
            }
        } else {
            for my $k (keys %{$d->{'D'}}) {
                next if (exists $d->{'D'}->{$k}->{'U'});
                if (exists $d->{'D'}->{$k}->{'D'} or exists $d->{'D'}->{$k}->{'C'}) {
                    patch(ref $s->{$k} ? $s->{$k} : \$s->{$k}, $d->{'D'}->{$k});
                    next;
                }
                if (exists $d->{'D'}->{$k}->{'A'}) {
                    $s->{$k} = $d->{'D'}->{$k}->{'A'};
                    next;
                }
                delete $s->{$k} if (exists $d->{'D'}->{$k}->{'R'});
            }
        }
    }

    return 1;
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
