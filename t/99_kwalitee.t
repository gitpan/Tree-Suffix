use strict;
use Test::More;

if ( ($ENV{CPAN_AUTHOR_TESTS}||'') !~ /\bTree::Suffix\b/ ) {
    plan skip_all => 'author tests';
}

eval { require Test::Kwalitee; Test::Kwalitee->import() };
if ($@) {
    plan skip_all => 'Test::Kwalitee not installed; skipping';
}
