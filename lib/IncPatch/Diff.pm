#!/usr/bin/env perl
package IncPatch::Diff;
use Moose;
use Moose::Util::TypeConstraints;
use IncPatch::Hunk;

enum DiffType => qw(unified standard contextual rcs ed);

has contents =>
(
    isa => 'Str',
    is  => 'ro',
);

has hunks =>
(
    isa => 'ArrayRef',
    is  => 'ro',
);

has diff_type =>
(
    isa => 'DiffType',
    is  => 'ro',
);

=head2 new

Wraps new such that you can pass in just a flat diff and it will parse and
inflate it properly.

=cut

around new => sub
{
    my $orig = shift;
    my $self = shift;

    if (@_ == 1)
    {
        @_ = $self->parse_diff(shift);
    }

    $self->$orig(@_);
};

=head2 parse_diff DIFF

This will turn a flat diff into the arguments needed for IncPatch::Diff's
constructor.

=cut

sub parse_diff
{
    my $self = shift;
    my $diff = shift;

    my $type = $self->guess_type($diff);
    my $method = 'parse_' . $type;

    die "Unable to parse '$type' diffs"
        unless $self->can($method);

    my $parsed = $self->$method($diff);

    return
        contents        => $diff,
        hunks           => $parsed->{hunks},
        diff_type       => $type,
}

=head2 guess_type

This will attempt to guess the type of the diff by looking at it.

It currently just returns unified because that's all we support right now.

=cut

sub guess_type { 'unified' }

=head2 parse_unified DIFF

Parses a unified diff. Returns a hashref containing:

=over 4

=item hunks

An arrayref of IncPatch::Hunk objects.

=back

=cut


sub parse_unified
{
    my $self = shift;
    my $diff = shift;

    open my $diff_fh, '<', \$diff;

    my $invocation;

    my @hunks;

    my ($from_file, $from_timestamp, $to_file, $to_timestamp);
    my $lines_affected;
    my @lines;

    while (<$diff_fh>)
    {
        if (/^diff/)
        {
            chomp($invocation = $_);
            # always start of a new hunk, except the first time around
            if (defined $lines_affected)
            {
                push @hunks, IncPatch::Hunk->new
                (
                    diff_invocation => $invocation,
                    from_file       => $from_file,
                    from_timestamp  => $from_timestamp,
                    to_file         => $to_file,
                    to_timestamp    => $to_timestamp,
                    lines_affected  => $lines_affected,
                    lines           => [@lines],
                );
                undef $_ for $lines_affected, $from_file, $from_timestamp, $to_file, $to_timestamp;
                @lines = ();
            }
            next;
        }

        if (/^--- (.+)\t([\d:. +-]+)$/    # regular diff
         || /^--- (.+)\s+(\(.*?\))$/      # svn/svk
        )
        {
            $from_file = $1;
            $from_timestamp = $2;
            next;
        }

        if (/^\+\+\+ (.+)\t([\d:. +-]+)$/    # regular diff
         || /^\+\+\+ (.+)\s+(\(.*?\))$/      # svn/svk
        )
        {
            $to_file = $1;
            $to_timestamp = $2;
            next;
        }

        if (/^\@\@ (.+) \@\@$/)
        {
            if (defined $lines_affected)
            {
                push @hunks, IncPatch::Hunk->new
                (
                    diff_invocation => $invocation,
                    from_file       => $from_file,
                    from_timestamp  => $from_timestamp,
                    to_file         => $to_file,
                    to_timestamp    => $to_timestamp,
                    lines_affected  => $lines_affected,
                    lines           => [@lines],
                );
                @lines = ();
            }

            $lines_affected = $1;
            next;
        }

        push @lines, $_
            if defined $from_file; # otherwise it's a pre-patch comment
    }

    # and finally, everything to the end of the file
    push @hunks, IncPatch::Hunk->new
    (
        diff_invocation => $invocation,
        from_file       => $from_file,
        from_timestamp  => $from_timestamp,
        to_file         => $to_file,
        to_timestamp    => $to_timestamp,
        lines_affected  => $lines_affected,
        lines           => \@lines,
    );

    return { hunks => \@hunks };
}

1;

