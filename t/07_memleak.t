use strict;
use Test::More;
use Tree::Suffix;

plan skip_all => 'For development only';
#plan tests => 3;

sub mem
{
  my $mem = (`ps -p $$ -o rss`)[1];
  $mem =~ s/^\s*|\s*$//g;
  return $mem;
}

{
  my $tree = Tree::Suffix->new();
  my $start = mem;
  for (my $i=0; $i<10_000; $i++)
  {
    my $tree = Tree::Suffix->new();
  }
  my $end = mem;
  ok($end - $start < 1_000, 'new()');
}

{
  my $tree = Tree::Suffix->new();
  $tree->insert('aa'..'gg');
  my $start = mem;
  for (my $i=0; $i<200; $i++)
  {
    $tree->clear;
    $tree->insert('aa'..'gg');
  }
  my $end = mem;
  ok($end - $start < 1_000, 'insert()');
  diag("\nMemory: $start -> $end");
}

{
  my $tree = Tree::Suffix->new();
  $tree->insert('aa'..'gg');
  my $start = mem;
  for (my $i=0; $i<200; $i++)
  {
    $tree = Tree::Suffix->new();
    $tree->insert('aa'..'gg');
  }
  my $end = mem;
  ok($end - $start < 1_000, 'new()/insert()');
  diag("\nMemory: $start -> $end");
}
