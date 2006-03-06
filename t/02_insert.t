use strict;
use Test::More tests => 5;
use Tree::Suffix;

{
  my $tree = Tree::Suffix->new();
  $tree->insert($_) for qw(string stringy astring);
  ok($tree->strings, 'strings');
  ok($tree->nodes, 'nodes');
  is($tree->strings, 3, 'insert($)');
}

{
  my $tree = Tree::Suffix->new();
  $tree->insert(qw(string stringy astring));
  is($tree->nodes, 11, 'insert(@)');
  is_deeply([$tree->strings], [0, 1, 2], 'strings() in list context');
}
