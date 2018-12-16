# NAME

Struct::Diff - Recursive diff for nested perl structures

<a href="https://travis-ci.org/mr-mixas/Struct-Diff.pm"><img src="https://travis-ci.org/mr-mixas/Struct-Diff.pm.svg?branch=master" alt="Travis CI"></a>
<a href='https://coveralls.io/github/mr-mixas/Struct-Diff.pm?branch=master'><img src='https://coveralls.io/repos/github/mr-mixas/Struct-Diff.pm/badge.svg?branch=master' alt='Coverage Status'/></a>
<a href="https://badge.fury.io/pl/Struct-Diff"><img src="https://badge.fury.io/pl/Struct-Diff.svg" alt="CPAN version"></a>

# VERSION

Version 0.97

# SYNOPSIS

    use Struct::Diff qw(diff list_diff split_diff patch valid_diff);

    $x = {one => [1,{two => 2}]};
    $y = {one => [1,{two => 9}],three => 3};

    $diff = diff($x, $y, noO => 1, noU => 1); # omit unchanged items and old values
    # $diff == {D => {one => {D => [{D => {two => {N => 9}},I => 1}]},three => {A => 3}}}

    @list_diff = list_diff($diff); # list (path and ref pairs) all diff entries
    # @list_diff == ({K => ['one']},[1],{K => ['two']}],\{N => 9},[{K => ['three']}],\{A => 3})

    $splitted = split_diff($diff);
    # $splitted->{a} # does not exist
    # $splitted->{b} == {one => [{two => 9}],three => 3}

    patch($x, $diff); # $x now equal to $y by structure and data

    @errors = valid_diff($diff);

# EXPORT

Nothing is exported by default.

# DIFF FORMAT

Diff is simply a HASH whose keys shows status for each item in passed
structures. Every status type (except `D`) may be omitted during the diff
calculation. Disabling some or other types produce different diffs: diff with
only unchanged items is also possible (when all other types disabled).

- A

    Stands for 'added' (exist only in second structure), it's value - added item.

- D

    Means 'different' and contains subdiff. The only status type which can't be
    disabled.

- I

    Index for array item, used only when prior item was omitted.

- N

    Is a new value for changed item.

- O

    Alike `N`, `O` is a changed item's old value.

- R

    Similar for `A`, but for removed items.

- U

    Represent unchanged items.

Diff format: metadata alternates with data and, as a result, diff may
represent any structure of any data types. Simple types specified as is,
arrays and hashes contain subdiffs for their items with native for such types
addressing: indexes for arrays and keys for hashes.

Sample:

    old:  {one => [5,7]}
    new:  {one => [5],two => 2}
    opts: {noU => 1} # omit unchanged items

    diff:
    {D => {one => {D => [{I => 1,R => 7}]},two => {A => 2}}}
    ||    | |     ||    |||    | |    |     |     ||    |
    ||    | |     ||    |||    | |    |     |     ||    +- with value 2
    ||    | |     ||    |||    | |    |     |     |+- key 'two' was added (A)
    ||    | |     ||    |||    | |    |     |     +- subdiff for it
    ||    | |     ||    |||    | |    |     +- another key from top-level hash
    ||    | |     ||    |||    | |    +- what it was (item's value: 7)
    ||    | |     ||    |||    | +- what happened to item (R - removed)
    ||    | |     ||    |||    +- array item's actual index
    ||    | |     ||    ||+- prior item was omitted
    ||    | |     ||    |+- subdiff for array item
    ||    | |     ||    +- it's value - ARRAY
    ||    | |     |+- it is deeply changed
    ||    | |     +- subdiff for key 'one'
    ||    | +- it has key 'one'
    ||    +- top-level thing is a HASH
    |+- changes somewhere deeply inside
    +- diff is always a HASH

# SUBROUTINES

## diff

Returns recursive diff for two passed things.

    $diff  = diff($x, $y, %opts);
    $patch = diff($x, $y, noU => 1, noO => 1, trimR => 1); # smallest diff

Beware changing diff: it's parts are references to substructures of passed
arguments.

### Options

- freezer `<sub>`

    Serializer callback (redefines default serializer). ["freeze" in Storable](https://metacpan.org/pod/Storable#freeze) is used
    by default, see ["CONFIGURATION VARIABLES"](#configuration-variables) for details.

- noX `<true|false>`

    Where X is a status (`A`, `N`, `O`, `R`, `U`); such status will be
    omitted.

- trimR `<true|false>`

    Drop removed item's data.

## list\_diff

List all pairs (path-to-subdiff, ref-to-subdiff) for provided diff. See
["ADDRESSING SCHEME" in Struct::Path](https://metacpan.org/pod/Struct::Path#ADDRESSING-SCHEME) for path format specification.

    @list = list_diff($diff);

### Options

- depth `<int>`

    Don't dive deeper than defined number of levels; `undef` used by default
    (unlimited).

- sort `<sub|true|false>`

    Defines how to handle hash subdiffs. Keys will be picked randomly (default
    `keys` behavior), sorted by provided subroutine (if value is a coderef) or
    lexically sorted if set to some other true value.

## split\_diff

Divide diff to pseudo original structures.

    $structs = split_diff(diff($x, $y));
    # $structs->{a}: items from $x
    # $structs->{b}: items from $y

## patch

Apply diff.

    patch($target, $diff);

## valid\_diff

Validate diff structure. In scalar context returns `1` for valid diff,
`undef` otherwise. In list context returns list of pairs (path, type) for
each error. See ["ADDRESSING SCHEME" in Struct::Path](https://metacpan.org/pod/Struct::Path#ADDRESSING-SCHEME) for path format
specification.

    @errors_list = valid_diff($diff); # list context

or

    $is_valid = valid_diff($diff); # scalar context

# CONFIGURATION VARIABLES

- $Struct::Diff::FREEZER

    Contains reference to default serialization function (`diff()` rely on it
    to determine data equivalency). ["freeze" in Storable](https://metacpan.org/pod/Storable#freeze) with enabled
    `$Storable::canonical` and `$Storable::Deparse` opts used by default.

    [Data::Dumper](https://metacpan.org/pod/Data::Dumper) is suitable for structures with regular expressions:

        use Data::Dumper;

        $Struct::Diff::FREEZER = sub {
            local $Data::Dumper::Deparse    = 1;
            local $Data::Dumper::Sortkeys   = 1;
            local $Data::Dumper::Terse      = 1;

            return Dumper @_;
        }

    But comparing to [Storable](https://metacpan.org/pod/Storable) it has two another issues: speed and unability
    to distinguish numbers from their string representations.

# LIMITATIONS

Only arrays and hashes traversed. All other types compared by reference
addresses and serialized content.

["freeze" in Storable](https://metacpan.org/pod/Storable#freeze) (serializer used by default) will fail serializing compiled
regexps, so, consider to use other serializer if data contains regular
expressions. See ["CONFIGURATION VARIABLES"](#configuration-variables) for details.

Struct::Diff will fail on structures with loops in references;
`has_circular_ref` from [Data::Structure::Util](https://metacpan.org/pod/Data::Structure::Util) can help to detect such
structures.

# AUTHOR

Michael Samoglyadov, `<mixas at cpan.org>`

# BUGS

Please report any bugs or feature requests to
`bug-struct-diff at rt.cpan.org`, or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff). I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

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

[Algorithm::Diff](https://metacpan.org/pod/Algorithm::Diff), [Data::Deep](https://metacpan.org/pod/Data::Deep), [Data::Diff](https://metacpan.org/pod/Data::Diff), [Data::Difference](https://metacpan.org/pod/Data::Difference),
[JSON::Patch](https://metacpan.org/pod/JSON::Patch), [JSON::MergePatch](https://metacpan.org/pod/JSON::MergePatch), [Struct::Diff::MergePatch](https://metacpan.org/pod/Struct::Diff::MergePatch)

[Data::Structure::Util](https://metacpan.org/pod/Data::Structure::Util), [Struct::Path](https://metacpan.org/pod/Struct::Path), [Struct::Path::PerlStyle](https://metacpan.org/pod/Struct::Path::PerlStyle)

# LICENSE AND COPYRIGHT

Copyright 2015-2018 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
