#!perl
package IncPatch;
use strict;
use warnings;
use IncPatch::Diff;
use IncPatch::UI;

=head1 NAME

IncPatch - incrementally apply diffs with patch, a la darcs

=head1 VERSION

Version 0.02 released 27 Oct 07

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    incpatch -p1 big-patch.diff big-patch2.diff

=head1 DESCRIPTION

IncPatch lets you incrementally apply one or more diffs. For example, you may
have a diff that implements two separate features, and you only want one of
them. You could manually chop the diff up into two, but that is tedious and
potentially error-prone -- are you sure you got the headers right?

Thankfully people are starting to take version control very seriously, so diff
and patch are being ushered to the backstage. But they're still important! I
use IncPatch to help manage many small but incomplete changes to large
codebases. C<< svk diff > misc.diff >>, C<svk revert --recursive .>, then I can
pull in any little changes from C<misc.diff> that I want with IncPatch without
them getting in the way of every commit.

The interface is very similar to that of C<darcs record>, because if you're
going to imitate, you might as well imitate the best of them.

=head1 COMMANDS

=over 4

=item C<y>

Apply this hunk.

=item C<n>

Don't apply this hunk.

=item C<f>

Apply the rest of the hunks to this file.

=item C<s>

Don't apply the rest of the hunks to this file.

=item C<a>

Apply all the remaining hunks.

=item C<d>

Apply selected hunks.

=item C<j>

Skip to next hunk.

=item C<k>

Back up to previous hunk.

=item C<p>

View this hunk in your pager.

=item C<e>

Edit this hunk in your editor.

=item C<?>

Show this help.

=item C<Space>

Accept the current default (which is capitalized).

=item C<q>

Quit IncPatch. Apply no hunks.

=back

=head1 TODO

=over 4

=item

IncPatch currently only knows about unified diffs. It should include support
contextual diffs, maybe even ed diffs :) It really just needs to know how to
split a diff up.

Self: look at L<patch>, which parses the four common diff forms.

=item

I'm positive there are a few corner cases IncPatch probably misses, even for
the one supported format.

I know that SVK's diffs don't play well, but maybe that's SVK's fault? :)

=item

The command line client C<incpatch> could use a bit of love in its argument
parsing.

=item

The 'e' command needs to update lines_affected for you.

=item

Handle receiving diffs on STDIN, perhaps using perlfaq8's HotKey module.

=item

Add an argument to spit out the unused hunks.

=item

Make the colors configurable, and by default off.

=item

A "real" man page.

=item

Build more concise patches so that patch doesn't repeat itself with many hunks.

=item

C<darcs> has a notion of "waiting" hunks, with the C<w> command. I haven't
grokked what this actually does yet. It certainly affects other commands.

=item

Improve the various interfaces. We at least want IncPatch::Hunk to be an
abstract base class, with C<to_patch> and C<display> methods. Then we'd have IncPatch::Hunk::Unified, IncPatch::Hunk::Contextual, etc.

=back

=head1 SEE ALSO

C<darcs>, L<SVK::Command::Commit>, L<SVK::Editor::InteractiveStatus>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 CODE

The code lives in a darcs repository at L<http://sartak.org/code/cpan/IncPatch/>

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-incpatch at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IncPatch>.

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc IncPatch

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IncPatch>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IncPatch>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IncPatch>

=item * Search CPAN

L<http://search.cpan.org/dist/IncPatch>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2007 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

