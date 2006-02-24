package Tree::Suffix;

use strict;
use vars qw($VERSION @ISA);

$VERSION = '0.01';

require XSLoader;
XSLoader::load('Tree::Suffix', $VERSION);

*longest_common_substrings   = \&lcs;
*longest_repeated_substrings = \&lrs;


1;

__END__

=head1 NAME

Tree::Suffix - Perl interface to the libstree library

=head1 SYNOPSIS

  use Tree::Suffix;

  $tree = Tree::Suffix->new;
  $tree = Tree::Suffix->new(@strings);
  
  $tree->insert(@strings);
  $tree->remove(@strings);

  @lcs = $tree->lcs;
  @lcs = $tree->lcs($min_len, $max_len);
  @lcs = $tree->longest_common_substrings;

  @lrs = $tree->lrs;
  @lrs = $tree->lrs($min_len, $max_len);
  @lrs = $tree->longest_repeated_substrings;

  $num = $tree->strings;
  $num = $tree->nodes;

  $tree->clear;
  $tree->dump;

=head1 DESCRIPTION

The C<Tree::Suffix> module provides an interface to the C library libstree,
which implements generic suffix trees.

=head1 METHODS

=over 4

=item $tree = Tree::Suffix->new

=item $tree = Tree::Suffix->new(@strings)

Creates a new Tree::Suffix object. The constructor will also accept a list 
of strings to be inserted into the tree.

=item $tree->insert(@strings)

Inserts the list of strings into the tree.

=item $tree->remove(@strings);

Remove the list of strings from the tree.

=item $tree->lcs

=item $tree->lcs($min_len, $max_len)

=item $tree->longest_common_substrings;

Returns a list of the longest common substrings. The minimum and maximum
length of the considered substrings may also be specified.

=item $tree->lrs

=item $tree->lrs($min_len, $max_len)

=item $tree->longest_repeated_substrings;

Returns a list of the longest repeated substrings. The minimum and maximum
length of the considered substrings may also be specified.

=item $tree->strings

Returns the total number of strings in the tree.

=item $tree->nodes

Returns the total number of nodes in the tree.

=item $tree->clear

Removes all strings from the tree.

=item $tree->dump

Prints a representation of the tree to STDOUT.

=back

=head1 EXAMPLE

To find the longest palindrome of a string:

  use Tree::Suffix;
  $str   = 'mississippi';
  $tree  = Tree::Suffix->new($str, scalar reverse $str);
  ($pal) = $tree->lcs;
  print "Longest palindrome: $pal\n";

This would print:

  Longest palindrome: ississi

=head1 SEE ALSO

libstree L<http://www.cl.cam.ac.uk/~cpk25/libstree/>

L<SuffixTree>

L<http://en.wikipedia.org/wiki/Suffix_tree>

=head1 BUGS AND REQUESTS

There appears to be a memory leak somewhere.  It is currently being 
investigated.

Please report any bugs or feature requests to C<bug-tree-suffix at 
rt.cpan.org>, or through the web interface at 
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tree-Suffix>. I will be 
notified, and then you'll automatically be notified of progress on your 
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tree::Suffix

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tree-Suffix>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tree-Suffix>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tree-Suffix>

=item * Search CPAN

L<http://search.cpan.org/dist/Tree-Suffix>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 gray <gray at cpan.org>, all rights reserved.

Copyright (C) 2003 Christian Kreibich <christian@whoop.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

gray, C<< <gray at cpan.org> >>

=cut
