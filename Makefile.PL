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
        'Storable'   => 0,
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Struct-Diff-*' },
);
