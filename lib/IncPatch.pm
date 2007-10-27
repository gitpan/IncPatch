#!perl
package IncPatch;
use strict;
use warnings;
use IncPatch::Diff;
use IncPatch::UI;

=head1 NAME

IncPatch - incrementally apply diffs

=head1 VERSION

Version 0.01 released 27 Oct 07

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    incpatch -p1 big-patch.diff big-patch2.diff

=head1 DESCRIPTION

IncPatch lets you incrementally apply one or more diffs. For example, you may
have a diff that implements two separate features, and you only want one of
them. You could manually chop the diff up into two, but that is tedious and
potentially error-prone.

The interface is very very similar to that of C<darcs record>.

=head1 TODO

=over 4

=item

IncPatch currently only knows about unified diffs. It should include support
contextual diffs, maybe even ed diffs :) It really just needs to know how to
split a diff up.

=item

I'm positive there are a few corner cases IncPatch probably misses, even for
the one supported format.

I know that SVK's diffs don't play well, but maybe that's SVK's fault? :)

=item

The command line client C<incpatch> could use a bit of love in its argument
parsing.

=item

'e' command to edit the hunk. This may be a power-user only command, so much
so that it would be hidden from the main "Shall I.." prompt.

=back

=head1 SEE ALSO

C<darcs>, L<SVK::Command::Commit>, L<SVK::Editor::InteractiveStatus>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

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

