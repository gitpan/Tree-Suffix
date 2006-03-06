use strict;
use Test::More tests => 4;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(string stringy astring astringy));
ok($tree->find('sting') == 0, 'find() non-existent substring');
ok($tree->find('string'), 'find() existing string');
ok($tree->find('stri'), 'find() existing prefix');
ok($tree->find('ing'), 'find() existing suffix');

