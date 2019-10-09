#!perl -T

use strict;
use warnings FATAL => 'all';

use Test::More;

use lib "t";
use _common;

my $one;
my @TESTS = (
    {
        a       => [],
        b       => {},
        name    => 'empty_list_vs_empty_hash',
        diff    => {N => {},O => []},
    },
    {
        a       => [],
        b       => [],
        name    => 'empty_list_vs_empty_list',
        diff    => {U => []},
    },
    {
        a       => [],
        b       => [],
        name    => 'empty_list_vs_empty_list_noU',
        diff    => {},
        opts    => {noU => 1},
    },
    {
        a       => [],
        b       => [0],
        name    => 'empty_list_vs_list_with_one_item',
        diff    => {D => [{A => 0}]},
    },
    {
        a       => [],
        b       => [0],
        name    => 'empty_list_vs_list_with_one_item_noA',
        diff    => {},
        opts    => {noA => 1},
        patched => [],
    },
    {
        a       => [0],
        b       => [],
        name    => 'list_with_one_item_vs_empty_list',
        diff    => {D => [{R => 0}]},
    },
    {
        a       => [0],
        b       => [],
        name    => 'list_with_one_item_vs_empty_list_noR',
        diff    => {},
        opts    => {noR => 1},
        patched => [0],
    },
    {
        a       => [0],
        b       => [1],
        name    => 'lists_with_one_different_item',
        diff    => {D => [{N => 1,O => 0}]},
    },
    {
        a       => [0],
        b       => [1],
        name    => 'lists_with_one_different_item_noN',
        diff    => {D => [{O => 0}]},
        opts    => {noN => 1},
        patched => [0],
    },
    {
        a       => [0],
        b       => [1],
        name    => 'lists_with_one_different_item_noO',
        diff    => {D => [{N => 1}]},
        opts    => {noO => 1},
    },
    {
        a       => [0],
        b       => [0, 1],
        name    => 'one_item_pushed_to_list',
        diff    => {D => [{U => 0},{A => 1}]},
    },
    {
        a       => [0],
        b       => [0, 1],
        name    => 'one_item_pushed_to_list_noU',
        diff    => {D => [{A => 1,I => 1}]},
        opts    => {noU => 1},
    },
    {
        a       => [0, 1],
        b       => [0],
        name    => 'one_item_popped_from_list',
        diff    => {D => [{U => 0},{R => 1}]},
    },
    {
        a       => [0, 1],
        b       => [0],
        name    => 'one_item_popped_from_list_noU',
        diff    => {D => [{I => 1,R => 1}]},
        opts    => {noU => 1},
    },
    {
        a       => [0, 1],
        b       => [1],
        name    => 'one_item_shifted_from_list',
        diff    => {D => [{R => 0},{U => 1}]},
    },
    {
        a       => [0, 1],
        b       => [1],
        name    => 'one_item_shifted_from_list_noU',
        diff    => {D => [{R => 0}]},
        opts    => {noU => 1},
    },
    {
        a       => [1],
        b       => [0, 1],
        name    => 'one_item_unshifted_to_list',
        diff    => {D => [{A => 0},{U => 1}]},
    },
    {
        a       => [1],
        b       => [0, 1],
        name    => 'one_item_unshifted_to_list_noU',
        diff    => {D => [{A => 0}]},
        opts    => {noU => 1},
    },
    {
        a       => [0, 1, 2],
        b       => [0, 9, 2],
        name    => 'one_item_changed_in_the_middle_of_list',
        diff    => {D => [{U => 0},{N => 9,O => 1},{U => 2}]},
    },
    {
        a       => [0, 1, 2],
        b       => [0, 9, 2],
        name    => 'one_item_changed_in_the_middle_of_list_noN',
        diff    => {D => [{U => 0},{O => 1},{U => 2}]},
        opts    => {noN => 1},
        patched => [0, 1, 2],
    },
    {
        a       => [0, 1, 2],
        b       => [0, 9, 2],
        name    => 'one_item_changed_in_the_middle_of_list_noO',
        diff    => {D => [{U => 0},{N => 9},{U => 2}]},
        opts    => {noO => 1},
    },
    {
        a       => [0, 1, 2],
        b       => [0, 9, 2],
        name    => 'one_item_changed_in_the_middle_of_list_noNO',
        diff    => {D => [{U => 0},{I => 2,U => 2}]},
        opts    => {noN => 1,noO => 1},
        patched => [0, 1, 2],
    },
    {
        a       => [0, 1, 2],
        b       => [0, 9, 2],
        name    => 'one_item_changed_in_the_middle_of_list_noU',
        diff    => {D => [{I => 1,N => 9,O => 1}]},
        opts    => {noU => 1},
    },
    {
        a       => [0, 2],
        b       => [0, 1, 2],
        name    => 'one_item_inserted_in_the_middle_of_list',
        diff    => {D => [{U => 0},{A => 1},{U => 2}]},
    },
    {
        a       => [0, 2],
        b       => [0, 1, 2],
        name    => 'one_item_inserted_in_the_middle_of_list_noA',
        diff    => {D => [{U => 0},{I => 1,U => 2}]},
        opts    => {noA => 1},
        patched => [0, 2],
    },
    {
        a       => [0, 2],
        b       => [0, 1, 2],
        name    => 'one_item_inserted_in_the_middle_of_list_noU',
        diff    => {D => [{A => 1,I => 1}]},
        opts    => {noU => 1},
    },
    {
        a       => [0, 1, 2],
        b       => [0, 2],
        name    => 'one_item_removed_from_the_middle_of_list',
        diff    => {D => [{U => 0},{R => 1},{U => 2}]},
    },
    {
        a       => [0, 1, 2],
        b       => [0, 2],
        name    => 'one_item_removed_from_the_middle_of_list_noR',
        diff    => {D => [{U => 0},{I => 2,U => 2}]},
        opts    => {noR => 1},
        patched => [0, 1, 2],
    },
    {
        a       => [0, 1, 2],
        b       => [0, 2],
        name    => 'one_item_removed_from_the_middle_of_list_noU',
        diff    => {D => [{I => 1,R => 1}]},
        opts    => {noU => 1},
    },
    {
        a       => [[0]],
        b       => [[0]],
        name    => 'nested_lists_with_one_equal_item',
        diff    => {U => [[ 0 ]]},
    },
    {
        a       => [[0]],
        b       => [[0]],
        name    => 'nested_lists_with_one_equal_item_noU',
        diff    => {},
        opts    => {noU => 1},
    },
    {
        a       => [[0]],
        b       => [[1]],
        name    => 'nested_lists_with_one_different_item',
        diff    => {D => [{D => [{N => 1,O => 0}]}]},
    },
    {
        a       => [],
        b       => [[[0, 1]]],
        name    => 'empty_list_vs_deeply_nested_list',
        diff    => {D => [{A => [[0,1]]}]},
    },
    {
        a       => [[[0, 1]]],
        b       => [],
        name    => 'deeply_nested_list_vs_empty_list',
        diff    => {D => [{R => [[0,1]]}]},
    },
    {
        a       => [[[0,1]]],
        b       => [],
        name    => 'deeply_nested_list_vs_empty_list_trimR',
        diff    => {D => [{R => undef}]},
        opts    => {trimR => 1}
    },
    {
        a       => [0, [[0, 1]]],
        b       => [0],
        name    => 'deeply_nested_sublist_removed_from_list',
        diff    => {D => [{U => 0},{R => [[0,1]]}]},
    },
    {
        a       => [0, [[0, 1]]],
        b       => [0],
        name    => 'deeply_nested_sublist_removed_from_list_trimR',
        diff    => {D => [{U => 0},{R => undef}]},
        opts    => {trimR => 1},
    },
    {
        a       => [[0]],
        b       => [[]],
        name    => 'sublist_emptied',
        diff    => {D => [{D => [{R => 0}]}]},
    },
    {
        a       => [[0]],
        b       => [[]],
        name    => 'sublist_emptied_noR',
        diff    => {},
        opts    => {noR => 1},
        patched => [[0]],
    },
    {
        a       => [[]],
        b       => [[0]],
        name    => 'sublist_filled',
        diff    => {D => [{D => [{A => 0}]}]},
    },
    {
        a       => [[]],
        b       => [[0]],
        name    => 'sublist_filled_noA',
        diff    => {},
        opts    => {noA => 1},
        patched => [[]],
    },
    {
        a       => [    2,3,  5,   ],
        b       => [0,1,2,3,4,5,6,7],
        name    => 'lists_LCS_added_items',
        diff    => {
            D => [
                {A => 0},
                {A => 1},
                {U => 2},
                {U => 3},
                {A => 4},
                {U => 5},
                {A => 6},
                {A => 7}
            ]
        },
    },
    {
        a       => [    2,3,  5,   ],
        b       => [0,1,2,3,4,5,6,7],
        name    => 'lists_LCS_added_items_noU',
        diff    => {
            D => [
                {A => 0},
                {A => 1},
                {A => 4,I => 2},
                {A => 6,I => 3},
                {A => 7}
            ]
        },
        opts    => {noU => 1},
    },
    {
        a       => [0,1,2,3,4,5,6,7],
        b       => [0,1,9,9,4,9,6,7],
        name    => 'lists_LCS_changed_items',
        diff    => {
            D => [
                {U => 0},
                {U => 1},
                {N => 9,O => 2},
                {N => 9,O => 3},
                {U => 4},
                {N => 9,O => 5},
                {U => 6},
                {U => 7}
            ]
        },
    },
    {
        a       => [0,1,2,3,4,5,6,7],
        b       => [0,1,9,9,4,9,6,7],
        name    => 'lists_LCS_changed_items_noU',
        diff    => {
            D => [
                {I => 2,N => 9,O => 2},
                {N => 9,O => 3},
                {I => 5,N => 9,O => 5}
            ]
        },
        opts    => {noU => 1},
    },
    {
        a       => [0,1,2,3,4,5,6,7],
        b       => [0,1,9,9,4,9,6,7],
        name    => 'lists_LCS_changed_items_noOU',
        diff    => {
            D => [
                {I => 2,N => 9},
                {N => 9},
                {I => 5,N => 9}
            ]
        },
        opts    => {noO =>1,noU => 1},
    },
    {
        a       => [0,1,2,3,4,5,6,7],
        b       => [    2,3,  5,   ],
        name    => 'lists_LCS_removed_items',
        diff    => {
            D => [
                {R => 0},
                {R => 1},
                {U => 2},
                {U => 3},
                {R => 4},
                {U => 5},
                {R => 6},
                {R => 7}
            ]
        },
    },
    {
        a       => [0,1,2,3,4,5,6,7],
        b       => [    2,3,  5,   ],
        name    => 'lists_LCS_removed_items_noU',
        diff    => {
            D => [
                {R => 0},
                {R => 1},
                {I => 4,R => 4},
                {I => 6,R => 6},
                {R => 7}
            ]
        },
        opts    => {noU => 1},
    },
    {
        a       => [ qw(a b c e h j l m n p) ],
        b       => [ qw(b c d e f j k l m r s t) ],
        name    => 'lists_LCS_complex',
        diff    => {
            D => [
                {R => 'a'},
                {U => 'b'},
                {U => 'c'},
                {A => 'd'},
                {U => 'e'},
                {N => 'f',O => 'h'},
                {U => 'j'},
                {A => 'k'},
                {U => 'l'},
                {U => 'm'},
                {N => 'r',O => 'n'},
                {N => 's',O => 'p'},
                {A => 't'}
            ]
        },
    },
    {
        a       => [ qw(a b c e h j l m n p) ],
        b       => [ qw(b c d e f j k l m r s t) ],
        name    => 'lists_LCS_complex_noU',
        diff    => {
            D => [
                {R => 'a'},
                {A => 'd',I => 3},
                {I => 4,N => 'f',O => 'h'},
                {A => 'k',I => 6},
                {I => 8,N => 'r',O => 'n'},
                {N => 's',O => 'p'},
                {A => 't'}
            ]
        },
        opts    => {noU => 1},
    },
    {
        a       => [ qw(a b c e h j l m n p) ],
        b       => [ qw(b c d e f j k l m r s t) ],
        name    => 'lists_LCS_complex_noAU',
        diff    => {
            D => [
                {R => 'a'},
                {I => 4,N => 'f',O => 'h'},
                {I => 8,N => 'r',O => 'n'},
                {N => 's',O => 'p'}
            ]
        },
        opts    => {noA => 1, noU => 1},
        patched => [ qw(b c e f j l m r s) ],
    },
    {
        a       => [ qw(a b c e h j l m n p) ],
        b       => [ qw(b c d e f j k l m r s t) ],
        name    => 'lists_LCS_complex_noRU',
        diff    => {
            D => [
                {A => 'd',I => 3},
                {I => 4,N => 'f',O => 'h'},
                {A => 'k',I => 6},
                {I => 8,N => 'r',O => 'n'},
                {N => 's',O => 'p'},
                {A => 't'}
            ]
        },
        opts    => {noR => 1, noU => 1},
        patched => [ qw(a b c d e f j k l m r s t) ],
    },
    {
        a       => [ qw(a b c e h j l m n p) ],
        b       => [ qw(b c d e f j k l m r s t) ],
        name    => 'lists_LCS_complex_onlyU',
        diff    => {
            D => [
                {I => 1,U => 'b'},
                {U => 'c'},
                {I => 3,U => 'e'},
                {I => 5,U => 'j'},
                {I => 6,U => 'l'},
                {U => 'm'}
            ]
        },
        opts    => {noA => 1, noN => 1, noO => 1, noR => 1},
        patched => ['a','b','c','e','h','j','l','m','n','p'],
    },
    {
        a       => $one = [ 0, 1, 2 ],
        b       => $one,
        name    => 'same_ref_lists',
        diff    => {U => [0,1,2]},
        to_json => 0,
    },
    {
        a       => [ 0, [[ 100 ]], [ 20, '30' ], 4 ],
        b       => [ 0, [[ 100 ]], [ 20, '31' ], 5 ],
        name    => 'nested_lists',
        diff    => {
            D => [
                {U => 0},
                {U => [[100]]},
                {
                    D => [
                        {U => 20},
                        {N => '31',O => '30'}
                    ]
                },
                {N => 5,O => 4}
            ]
        },
    },
    {
        a       => [ 0, [[ 100 ]], [ 20, '30' ], 4 ],
        b       => [ 0, [[ 100 ]], [ 20, '31' ], 5 ],
        name    => 'nested_lists_noU',
        diff    => {
            D => [
                {
                    D => [
                        {I => 1,N => '31',O => '30'}
                    ],
                    I => 2
                },
                {N => 5,O => 4}
            ]
        },
        opts    => {noU => 1},
    },
);

run_batch_tests(@TESTS);

done_testing();
