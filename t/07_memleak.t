use strict;
use Test::More;
use Tree::Suffix;

unless (mem()) {
    plan skip_all => 'Unable to determine memory usage via `ps` command';
}

plan tests => 2;

sub mem {
    my $mem = (`ps -p $$ -o rss`)[1];
    $mem =~ s/^\s*|\s*$//g;
    return $mem;
}

{
    my $tree = Tree::Suffix->new();
    $tree->insert('aa'..'gg');
    my $start = mem;
    for (my $i=0; $i<200; $i++) {
        $tree->clear;
        $tree->insert('aa'..'gg');
    }
    my $end = mem;
    if ($end - $start > 1_000) {
        diag("\nMemory: $start -> $end\nVerify that you have libstree >= 0.4.2");
        ok(0, 'insert()');
    }
    else {
        ok(1, 'insert()');
    }
}

{
    my $tree = Tree::Suffix->new();
    $tree->insert('aa'..'gg');
    my $start = mem;
    for (my $i=0; $i<200; $i++) {
        $tree = Tree::Suffix->new();
        $tree->insert('aa'..'gg');
    }
    my $end = mem;
    if ($end - $start > 1_000) {
        diag("\nMemory: $start -> $end\nVerify that you have libstree >= 0.4.2");
        ok(0, 'new()/insert()');
    }
    else {
        ok(1, 'new()/insert()');
    }
}
