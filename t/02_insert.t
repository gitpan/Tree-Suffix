use strict;
use Test::More tests => 4;
use Tree::Suffix;

{
  my $tree = Tree::Suffix->new();
  $tree->insert($_) for qw(string stringy astring);
  ok($tree->strings, 'strings');
  ok($tree->nodes, 'nodes');
  ok($tree->strings == 3, 'insert($)');
}

{
  my $tree = Tree::Suffix->new();
  $tree->insert(qw(string stringy astring));
  ok($tree->nodes == 11, 'insert(@)');
}
