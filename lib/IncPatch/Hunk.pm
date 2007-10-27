#!/usr/bin/env perl
package IncPatch::Hunk;
use Moose;

has lines =>
(
    is  => 'rw', # rw because user can edit the hunk in $EDITOR
    isa => 'ArrayRef',
);

has from_file =>
(
    is  => 'ro',
    isa => 'Str',
);

has to_file =>
(
    is  => 'ro',
    isa => 'Str',
);

has from_timestamp =>
(
    is  => 'ro',
    isa => 'Str',
);

has to_timestamp =>
(
    is  => 'ro',
    isa => 'Str',
);

has lines_affected =>
(
    is  => 'rw', # rw because user can edit the hunk in $EDITOR
    isa => 'Str',
);

has diff_invocation =>
(
    isa => 'Str',
    is  => 'ro',
);

=head2 as_string

Displays this hunk as a string suitable for passing directly to patch.

=cut

sub as_string
{
    my $self = shift;

    my $diff = << "HEADER";
@{[ $self->diff_invocation || '' ]}
--- @{[ $self->from_file ]}\t@{[ $self->from_timestamp ]}
+++ @{[ $self->to_file ]}\t@{[ $self->to_timestamp ]}
@@ @{[ $self->lines_affected ]} @@
HEADER
    $diff .= $_ for @{ $self->lines };

    $diff .= "\n" unless substr($diff, -1, 1) eq "\n";

    return $diff;
}

=head2 as_colored_string

Displays this hunk with vim's syntax coloring, for display to the user.

=cut

sub as_colored_string
{
    my $self = shift;

    my $diff = << "HEADER";
\e[0;32m@{[ $self->diff_invocation || '' ]}\e[m
\e[0;32m--- @{[ $self->from_file ]}\t@{[ $self->from_timestamp ]}\e[m
\e[0;32m+++ @{[ $self->to_file ]}\t@{[ $self->to_timestamp ]}\e[m
\e[0;33m@@ @{[ $self->lines_affected ]} @@\e[m
HEADER

    $diff .= $_ for map {
        $_ =~ /^-/
            ? "\e[0;35m$_\e[m"
        : $_ =~ /^\+/
            ? "\e[0;36m$_\e[m"
            : $_
    } @{$self->lines};

    $diff .= "\n" unless substr($diff, -1, 1) eq "\n";

    return $diff;
}

1;

