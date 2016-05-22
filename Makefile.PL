use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Struct::Diff',
    AUTHOR           => q{Michael Samoglyadov <mixas@cpan.org>},
    VERSION_FROM     => 'lib/Struct/Diff.pm',
    ABSTRACT_FROM    => 'lib/Struct/Diff.pm',
    LICENSE          => 'Perl_5',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Data::Compare'   => 0,
        'Pod::Markdown'   => 0,
        'Storable'        => 0,
        'Test::More'      => 0,
    },
    PREREQ_PM => {
        'Carp'            => 0,
        'parent'          => 0,
    },
    dist  => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
        PREOP    => 'pod2markdown lib/Struct/Diff.pm > README.md',
    },
    clean => { FILES => 'Struct-Diff-*' },
);
