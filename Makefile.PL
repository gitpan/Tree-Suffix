use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Tree::Suffix',
  VERSION_FROM  => 'lib/Tree/Suffix.pm',
  ABSTRACT_FROM => 'lib/Tree/Suffix.pm',
  AUTHOR        => 'gray <gray@cpan.org>',
  LIBS          => [ '-lstree' ],
  clean         => { FILES => 'Tree-Suffix-*' },
  dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
