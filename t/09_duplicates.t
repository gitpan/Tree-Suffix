use strict;
use Test::More tests => 7;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(string bling string));
ok($tree->strings == 3, 'string count');
ok($tree->remove(qw(string)) == 2, 'return count of remove');
ok($tree->strings == 1, 'remaining strings');
ok($tree->find('string') == 0, 'find removed string');

$tree->allow_duplicates(0);
ok(1, 'setting flag');
ok($tree->insert(qw(bling)) == 0, 'return count of insert');
ok($tree->strings == 1, 'string count');
