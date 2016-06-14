# NAME

Struct::Diff - Recursive diff tools for nested perl structures

# VERSION

Version 0.56

# SYNOPSIS

    use Struct::Diff qw(diff dselect dsplit patch);

    $a = {x => [7,{y => 4}]};
    $b = {x => [7,{y => 9}],z => 33};

    $diff = diff($a, $b, noO => 1, noU => 1);       # omit unchanged and old values for changed items
    # $diff == {D => {x => {D => [{I => 1,N => {y => 9}}]},z => {A => 33}}};

    @items = dselect($diff, fromD => ['z']);        # get status for a particular key
    # @items == ({z => {A => 33}});

    $href = dsplit($diff);                          # divide diff
    # $dsplit->{a} not exists                       # unchanged omitted, other items originated from $b
    # $dsplit->{b} == {x => [{y => 9}],z => 33};

    patch($a, $diff);
    # $a now equal to $b by structure and data

# EXPORT

Nothing exports by default

# SUBROUTINES

## diff

Returns HASH reference to diff between two passed things. Beware when
changing diff: some of it's substructures are links to original structures.

    $diff = diff($a, $b, %opts);
    $patch = diff($a, $b, noU => 1, noO => 1, trimR => '1'); # smallest possible diff

### Metadata format

Diff's keys shows status of each item in passed structures.

- A

    stands for 'added' (exists only in second structure), it's value - added item.

- D

    means 'different' and contains subdiff.

- I

    shows index for changed items (in arrays only).

- N

    is a new value for changed item.

- O

    Alike 'N', 'O' is a changed item's old value.

- R

    similar for 'A', but for removed items.

- U

    represent 'unchanged' items - common for both structures.

### Available options

- noX

    Where X is a status (A, N, O, R, U); such status will be omitted

- trimR

    Drop removed item's data

## dselect

Returns items with desired status from diff's first level

    @added = dselect($diff, states => { 'A' => 1 } # something added?
    @items = dselect($diff, states => { 'A' => 1, 'U' => 1 }, 'fromD' => [ 'a', 'b', 'c' ]) # from D hash
    @items = dselect($diff, states => { 'D' => 1, 'N' => 1 }, 'fromD' => [ 0, 1, 3, 5, 9 ]) # from D array

### Available options

- fromD

    Select items from diff's 'D'. Expects list of positions (indexes for arrays and keys for hashes). All items with
    specified states will be returned if opt exists, but not defined or is an empty list.

- states

    Expects hash with desired states as keys with values in some true value. Items with all states will be returned if
    opt not defined

## dsplit

Divide diff to pseudo original structures.

    $structs = dsplit($diff);
    # $structs->{'a'} - now contains items originated from original $a
    # $structs->{'b'} - same for $b

## patch

Apply diff.

    patch($a, $diff);

# LIMITATIONS

Struct::Diff fails on structures with loops in references. has\_circular\_ref from Data::Structure::Util can help
to detect such structures.

Only scalars, refs to scalars, ref to arrays and ref to hashes correctly traversed. All other data types compared
by their references.

No object oriented interface provided.

# AUTHOR

Michael Samoglyadov, `<mixas at cpan.org>`

# BUGS

Please report any bugs or feature requests to `bug-struct-diff at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff). I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Struct::Diff

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=Struct-Diff](http://rt.cpan.org/NoAuth/Bugs.html?Dist=Struct-Diff)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Struct-Diff](http://annocpan.org/dist/Struct-Diff)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Struct-Diff](http://cpanratings.perl.org/d/Struct-Diff)

- Search CPAN

    [http://search.cpan.org/dist/Struct-Diff/](http://search.cpan.org/dist/Struct-Diff/)

# SEE ALSO

[Data::Diff](https://metacpan.org/pod/Data::Diff), [Data::Difference](https://metacpan.org/pod/Data::Difference)

[Array::Diff](https://metacpan.org/pod/Array::Diff), [Array::Compare](https://metacpan.org/pod/Array::Compare), [Algorithm::Diff](https://metacpan.org/pod/Algorithm::Diff), [Data::Compare](https://metacpan.org/pod/Data::Compare), [Hash::Diff](https://metacpan.org/pod/Hash::Diff), [Test::Struct](https://metacpan.org/pod/Test::Struct),
[Struct::Compare](https://metacpan.org/pod/Struct::Compare)

[Data::Structure::Util](https://metacpan.org/pod/Data::Structure::Util), [Struct::Path](https://metacpan.org/pod/Struct::Path)

# LICENSE AND COPYRIGHT

Copyright 2015-2016 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
