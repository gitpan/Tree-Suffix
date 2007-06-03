use strict;
use Test::More;
use Tree::Suffix;

unless (mem()) {
    plan skip_all => 'Unable to determine memory usage via `ps` command';
}

plan tests => 1;

sub mem {
    my $mem = (`ps -p $$ -o rss`)[1];
    $mem =~ s/^\s*|\s*$//g;
    return $mem;
}

{
    my $str = "mississippi";
    my $tree = Tree::Suffix->new($str);

    my $start = mem;
    for (my $i=0; $i<100_000; $i++) {
        my @matches = $tree->find('is');
    }
    my $end = mem;
    if ($end - $start > 1_000) {
        diag("Memory leak: $start -> $end");
        ok(0, 'find()');
    }
    else {
        ok(1, 'find()');
    }
}
