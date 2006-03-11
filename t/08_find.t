use strict;
use Test::More tests => 8;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(string stringy astring astringy));
ok($tree->find('sting') == 0, 'non-existent substring');
ok($tree->find('string') == 4, 'existing string');
ok($tree->find('stri') == 4, 'existing prefix');
ok($tree->find('ing') == 4, 'existing suffix');

$tree = Tree::Suffix->new(qw(mississippi));
is_deeply(
  [$tree->find('mis')], [[0, 0, 2]], 'list context'
);
is_deeply(
  [sort_arefs($tree->find('ss'))], [[0, 2, 3], [0, 5, 6]], 'list context'
);

$tree = Tree::Suffix->new(qw(actgttact gactagcga gacacacta));
is_deeply(
  [sort_arefs($tree->find('act'))],
  [[0, 0, 2], [0, 6, 8], [1, 1, 3], [2, 5, 7]], 'list context'
);

is_deeply([$tree->find('virus')], [], 'no match in list context');


sub sort_arefs
{
  map  { $_->[0] }
  sort { $a->[1] cmp $b->[1] }
  map  { [$_, join(' ', @$_)] } 
  @_;
}
