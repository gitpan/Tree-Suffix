use strict;
use Test::More tests => 2;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(string stringy astring astringy));
ok($tree->remove(qw(stringy astringy)) == 2, 'return count');
ok($tree->strings == 2, 'remaining nodes');
