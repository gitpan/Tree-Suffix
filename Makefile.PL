use strict;
use ExtUtils::MakeMaker;

my $libs = join ' ', @ENV{qw(LDFLAGS LD_LIBRARY_PATH)};
my $inc  = join ' ', @ENV{qw(CFLAGS CXXFLAGS CPPFLAGS)};

WriteMakefile(
    NAME          => 'Tree::Suffix',
    VERSION_FROM  => 'lib/Tree/Suffix.pm',
    ABSTRACT_FROM => 'lib/Tree/Suffix.pm',
    AUTHOR        => 'gray <gray@cpan.org>',
    PREREQ_PM     => { 'Test::More' => 0 },
    LIBS          => [ "$libs -lstree" ],
    INC           => $inc,
    clean         => { FILES => 'Tree-Suffix-*' },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => '.gz', },
);
