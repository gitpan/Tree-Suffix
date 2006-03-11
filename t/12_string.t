use strict;
use Test::More no_plan => 7;
use Tree::Suffix;

my $tree = Tree::Suffix->new(qw(actgttact gactagcga gacacacta));
ok($tree->string(1) eq 'gactagcga', 'entire string');
ok($tree->string(2, 2) eq 'cacacta', 'substring w/ start pos');
ok($tree->string(2, 2, 5) eq 'caca', 'substring w/ start and end pos');
ok(! defined $tree->string(5), 'bad index');
ok(! defined $tree->string(1, -2, -5), 'bad start/end positions');
ok($tree->string(1, -2) eq 'gactagcga', 'bad start position');
ok($tree->string(1, 1, 23) eq 'actagcga', 'bad end position');
