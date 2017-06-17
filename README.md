# NAME

Struct::Diff - Recursive diff tools for nested perl structures

# VERSION

Version 0.88

# SYNOPSIS

    use Struct::Diff qw(diff list_diff split_diff patch);

    $a = {x => [7,{y => 4}]};
    $b = {x => [7,{y => 9}],z => 33};

    $diff = diff($a, $b, noO => 1, noU => 1); # omit unchanged items and old values
    # $diff == {D => {x => {D => [{I => 1,N => {y => 9}}]},z => {A => 33}}}

    @list_diff = list_diff($diff); # list (path and ref pairs) all diff entries
    # $list_diff == [[{keys => ['z']}],\{A => 33},[{keys => ['x']},[0]],\{I => 1,N => {y => 9}}]

    $splitted = split_diff($diff);
    # $splitted->{a} # not exists
    # $splitted->{b} == {x => [{y => 9}],z => 33}

    patch($a, $diff); # $a now equal to $b by structure and data

# EXPORT

Nothing is exported by default.

# DIFF METADATA FORMAT

Diff is simply a HASH whose keys shows status for each item in passed structures.

- A

    Stands for 'added' (exists only in second structure), it's value - added item.

- D

    Means 'different' and contains subdiff.

- I

    Index for changed array item.

- N

    Is a new value for changed item.

- O

    Alike `N`, `O` is a changed item's old value.

- R

    Similar for `A`, but for removed items.

- U

    Represent unchanged items.

# SUBROUTINES

## diff

Returns hashref to recursive diff between two passed things. Beware when
changing diff: some of it's substructures are links to original structures.

    $diff = diff($a, $b, %opts);
    $patch = diff($a, $b, noU => 1, noO => 1, trimR => 1); # smallest possible diff

### Options

- noX

    Where X is a status (`A`, `N`, `O`, `R`, `U`); such status will be omitted.

- trimR

    Drop removed item's data.

## dsplit

Is an alias for ["split_diff"](#split_diff). Deprecated, will be removed in future
releases. ["split_diff"](#split_diff) should be used instead.

## list\_diff

List pairs (path, ref\_to\_subdiff) for provided diff. See
["ADDRESSING SCHEME" in Struct::Path](https://metacpan.org/pod/Struct::Path#ADDRESSING-SCHEME) for path format specification.

    @list = list_diff(diff($frst, $scnd);

### Options

- depth <int>

    Don't dive deeper than defined number of levels.

- sort <sub|true|false>

    Defines how to traverse hash subdiffs. Keys will be picked randomely (`keys`
    behavior, default), sorted by provided subroutine (if value is a coderef) or
    lexically sorted if set to some other true value.

## split\_diff

Divide diff to pseudo original structures

    $structs = split_diff(diff($a, $b));
    # $structs->{a}: items originated from $a
    # $structs->{b}: same for $b

## dtraverse

Deprecated. ["list_diff"](#list_diff) should be used instead.

Traverse through diff invoking callback function for subdiff statuses.

    my $opts = {
        callback => sub { print "added value:", $_[0], "depth:", @{$_[1]}, "status:", $_[2]; return 1},
        sortkeys => sub { sort { $a <=> $b } @_ }   # numeric sort for keys under diff
    };
    dtraverse($diff, $opts);

### Options

- depth <int>

    Don't dive deeper than defined number of levels

- callback <sub>

    Mandatory option, must contain coderef to callback fuction. Four arguments will be passed to provided
    subroutine: value, path, status and ref to subdiff. Function must return some true value on success. Important:
    path (second argument) is actual for callback lifetime and will be immedeately changed afterwards.

- sortkeys <sub>

    Defines how will be traversed subdiffs for hashes. Keys will be picked randomely (depends on `keys` behavior,
    default), sorted by provided subroutine (if value is a coderef) or lexically sorted if set to some other true value.

- statuses <list>

    Exact list of statuses. Sequence defines invocation priority.

## patch

Apply diff

    patch($a, $diff);

# LIMITATIONS

Struct::Diff fails on structures with loops in references. `has_circular_ref`
from [Data::Structure::Util](https://metacpan.org/pod/Data::Structure::Util) can help to detect such structures.

Only scalars, refs to scalars, ref to arrays and ref to hashes correctly traversed.
All other data types compared by their references.

No object oriented interface provided.

# AUTHOR

Michael Samoglyadov, `<mixas at cpan.org>`

# BUGS

Please report any bugs or feature requests to `bug-struct-diff at rt.cpan.org`,
or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Struct-Diff). I will be notified,
and then you'll automatically be notified of progress on your bug as I make
changes.

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
[JSON::MergePatch](https://metacpan.org/pod/JSON::MergePatch)

[Data::Structure::Util](https://metacpan.org/pod/Data::Structure::Util), [Struct::Path](https://metacpan.org/pod/Struct::Path), [Struct::Path::PerlStyle](https://metacpan.org/pod/Struct::Path::PerlStyle)

# LICENSE AND COPYRIGHT

Copyright 2015-2017 Michael Samoglyadov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
