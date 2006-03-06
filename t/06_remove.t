use strict;
use Test::More tests => 3;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(string stringy astring astringy));
ok($tree->remove(qw(stringy astringy)) == 2, 'return count');
ok($tree->strings == 2, 'remaining nodes');
is_deeply([$tree->strings], [0, 2], 'strings() in list context');
