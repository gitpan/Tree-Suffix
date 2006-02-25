use strict;
use Test::More tests => 1;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(string stringy astring astringy));
$tree->remove(qw(stringy astringy));
ok($tree->strings == 2, 'remove');