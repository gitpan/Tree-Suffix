use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Tree::Suffix',
  VERSION_FROM  => 'lib/Tree/Suffix.pm',
  ABSTRACT_FROM => 'lib/Tree/Suffix.pm',
  PREREQ_PM     => { 'Test::More' => 1 },
  AUTHOR        => 'gray <gray@cpan.org>',
  LIBS          => [ '-lstree' ],
  dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
