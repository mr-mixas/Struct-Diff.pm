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
    use Struct::Diff qw(diff strip);

    my $diff = diff($ref1, $ref2);
    print Dumper $diff->['added'];
    print Dumper $diff->['changed'];
    print Dumper $diff->['common'];
    print Dumper $diff->['removed'];
    ...

=head1 EXPORT

Nothing exports by default

=head1 SUBROUTINES

=head2 diff

=cut

sub diff($$;@);
sub diff($$;@) {
    my ($frst, $scnd, %opts) = @_;
    $opts{'depth'}-- if (exists $opts{'depth'});
    my $diff = {};
    if (ref $frst ne ref $scnd) {
        $diff->{'changed'} = [$frst, $scnd];
    } elsif ((ref $frst eq 'ARRAY') and ($frst ne $scnd) and (not exists $opts{'depth'} or $opts{'depth'} >= 0)) {
        my $fc = [@{$frst}]; my $sc = [@{$scnd}]; # copy to new arrays to prevent original arrays corruption
        while (@{$fc} and @{$sc}) {
            my $fi = shift(@{$fc}); my $si = shift(@{$sc});
            my $tmp = diff($fi, $si, %opts);
            if (exists $tmp->{'added'} or exists $tmp->{'changed'} or exists $tmp->{'removed'}) {
                if ($opts{'separate-changed'}) {
                    push @{$diff->{'removed'}}, $fi;
                    push @{$diff->{'added'}}, $si;
                } else {
                    push @{$diff->{'changed'}}, [$fi, $si];
                    push @{$diff->{'changed'}->[-1]}, @{$frst} - @{$fc} - 1 if ($opts{'shortest'}); # add position in array for changed item
                }
            } else {
                push @{$diff->{'common'}}, $fi unless ($opts{'shortest'});
            }
        }
        push @{$diff->{'removed'}}, @{$fc} if (@{$fc});
        push @{$diff->{'added'}}, @{$sc} if (@{$sc});
    } elsif ((ref $frst eq 'HASH') and ($frst ne $scnd) and (not exists $opts{'depth'} or $opts{'depth'} >= 0)) {
        for my $key (keys { map { $_, 1 } (keys %{$frst}, keys %{$scnd}) }) { # go througth united uniq keys
            if (exists $frst->{$key} and exists $scnd->{$key}) {
                my $tmp = diff($frst->{$key}, $scnd->{$key}, %opts);
                if (exists $tmp->{'added'} or exists $tmp->{'changed'} or exists $tmp->{'removed'}) {
                    if ($opts{'separate-changed'}) {
                        $diff->{'removed'}->{$key} = $frst->{$key};
                        $diff->{'added'}->{$key} = $scnd->{$key};
                    } else {
                        push @{$diff->{'changed'}->{$key}}, $frst->{$key}, $scnd->{$key};
                    }
                } else {
                    $diff->{'common'}->{$key} = $frst->{$key} unless ($opts{'shortest'});
                }
            } elsif (exists $frst->{$key}) {
                $diff->{'removed'}->{$key} = $frst->{$key};
            } else {
                $diff->{'added'}->{$key} = $scnd->{$key};
            }
        }
    } else { # treat all other types as scalars
        unless ((not defined $frst and not defined $scnd) or ((defined $frst and defined $scnd) and ($frst eq $scnd))) {
            $diff->{'changed'} = [$frst, $scnd];
        }
    }
    $diff->{'common'} = $frst unless (keys %{$diff} or $opts{'shortest'}); # if passed srtucts are empty
    return $diff;
}

=head2 strip

=cut

sub strip($$);
sub strip($$) {
    my ($frst, $scnd) = @_;
    my $diff;
    if (ref $frst ne ref $scnd) {
        $diff->{'changed'} = [$frst, $scnd];
    } elsif (ref $frst eq 'ARRAY') {
        my $fa = [@{$frst}]; my $sa = [@{$scnd}]; # copy to new arrays to prevent original arrays corruption
        for (my $i = 0; @{$fa} and @{$sa}; $i++) {
            my $fi = shift(@{$fa}); my $si = shift(@{$sa});
            my $tmp = strip($fi, $si);
            if (exists $tmp->{'added'} or exists $tmp->{'changed'} or exists $tmp->{'removed'}) {
                push @{$diff->{'changed'}}, [$fi, $si];
            } else {
                splice @{$frst}, $i, 1;
                splice @{$scnd}, $i, 1;
                $i--;
            }
        }
        push @{$diff->{'removed'}}, @{$frst} if (@{$frst});
        push @{$diff->{'added'}}, @{$scnd} if (@{$scnd});
    } elsif (ref $frst eq 'HASH') {
        for my $key (keys { map { $_, 1 } (keys %{$frst}, keys %{$scnd}) }) { # go througth united uniq keys
            if (exists $frst->{$key} and exists $scnd->{$key}) {
                my $tmp = strip($frst->{$key}, $scnd->{$key});
                if (exists $tmp->{'added'} or exists $tmp->{'changed'} or exists $tmp->{'removed'}) {
                    push @{$diff->{'changed'}->{$key}}, $frst->{$key}, $scnd->{$key};
                } else {
                    delete $frst->{$key};
                    delete $scnd->{$key};
                }
            } elsif (exists $frst->{$key}) {
                $diff->{'removed'}->{$key} = $frst->{$key};
            } else {
                $diff->{'added'}->{$key} = $scnd->{$key};
            }
        }
    } else { # treat all types as scalars
        unless ((not defined $frst and not defined $scnd) or ((defined $frst and defined $scnd) and ($frst eq $scnd))) {
            $diff->{'changed'} = [$frst, $scnd];
        }
    }
    return $diff;
}

=head1 AUTHOR

Michael Samoglyadov, C<< <mixas at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-struct-diff at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff>.  I will be notified, and then you'll
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


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1; # End of Struct::Diff
