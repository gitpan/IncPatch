#!/usr/bin/env perl
package IncPatch::Hunk;
use Moose;

has lines =>
(
    is  => 'ro',
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
    is  => 'ro',
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

    return << "DIFF";
@{[ $self->diff_invocation || '' ]}
--- @{[ $self->from_file ]}\t@{[ $self->from_timestamp ]}
+++ @{[ $self->to_file ]}\t@{[ $self->to_timestamp ]}
@@ @{[ $self->lines_affected ]} @@
@{[ join "\n", @{$self->lines} ]}
DIFF
}

=head2 as_colored_string

Displays this hunk with vim's syntax coloring, for display to the user.

=cut

sub as_colored_string
{
    my $self = shift;

    return << "DIFF";
\e[0;32m@{[ $self->diff_invocation || '' ]}\e[m
\e[0;32m--- @{[ $self->from_file ]}\t@{[ $self->from_timestamp ]}\e[m
\e[0;32m+++ @{[ $self->to_file ]}\t@{[ $self->to_timestamp ]}\e[m
\e[0;33m@@ @{[ $self->lines_affected ]} @@\e[m
@{[ join "\n", map {
        $_ =~ /^-/ ? "\e[0;35m$_\e[m"
                   : $_ =~ /^\+/
                   ? "\e[0;36m$_\e[m"
                   : $_
    } @{$self->lines} ]}
DIFF
}

1;

