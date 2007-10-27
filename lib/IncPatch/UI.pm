#!/usr/bin/env perl
package IncPatch::UI;
use strict;
use warnings;
use Term::ReadKey;
use Term::CallEditor;
use IO::Pager;

=head2 to_user

Displays a line of text to the user. This is just a thin wrapper around print
that can be overridden.

=cut

sub to_user
{
    print @_;
}

=head2 read_key

Uses Term::ReadKey to read a single keystroke from the user. This will do
what it can to make sure the term is set back to the normal line-based mode,
especially if the user presses ^C.

=cut

sub read_key
{
    ReadMode(3);

    local $SIG{INT} = sub { ReadMode(0); exit; };
    my $c = ReadKey(0);
    ReadMode(0);
    die "Error reading key from user." if !defined($c);
    to_user $c;
    to_user "\n" unless $c eq "\n";

    return $c;
}

=head2 prompt_user PARAMHASH

Prompts the user for one keystroke, which represents a command. Very much inspired by darcs' interface here. Here are the possible arguments:

=over 4

=item hunk (required)

The IncPatch::Hunk object that we're concerned about

=item commands (required)

A hashreference mapping one-letter command to coderefs. The ? command must
always be present, unless you're of a malicious bent. One of these coderefs
will be returned for you to invoke.

All command letters should be lowercase or the special case of '?'.

=item change (required)

The number of the current hunk.

=item change_count (optional)

The total number of hunks we're going to ask the user about. If unspecified,
this uses ? a la darcs.

=item command_string (optional)

A string containing the one-letter commands. If not passed, it will first sort
the commands (after dropping the special-cased ? command) and join them into a
string.

=item default (optional)

The one-letter command to be used when the user just hits enter. This will
be capitalized in the command string (regardless of whether you explicitly
pass in command_string).

=item filter_string (optional)

If set to true, this will go through the provided command string and filter
out any command that isn't in the command table.

=item suppress_hunk (optional)

If set to true, this will avoid printing the hunk. That also means you don't
need to pass it in, but you should anyway.

=item color (optional)

If set to false, this will fall back to plain jane monochrome diffs. Boo!

=back

=cut

sub prompt_user
{
    my %args =
    (
        default      => '',
        change_count => '?',
        color        => 1,
        @_
    );

    unless ($args{suppress_hunk})
    {
        my $method = $args{color} ? 'as_colored_string' : 'as_string';
        to_user $args{hunk}->$method, "\n";
    }

    # we specify always help, so we don't want it in the command string
    my $help_cmd = delete $args{commands}->{'?'};

    if (exists $args{command_string})
    {
        if ($args{filter_string})
        {
            $args{command_string} = join '',
                                    map  { $_ eq $args{default} ? uc($_) : $_ }
                                    grep { exists $args{commands}->{$_} }
                                    split '',
                                    $args{command_string};
        }
    }
    else
    {
        $args{command_string} = join '',
                                map { $_ eq $args{default} ? uc($_) : $_ }
                                sort keys %{ $args{commands} };
    }

    $args{commands}->{'?'} = $help_cmd;

    my $c;

    while (1)
    {
        to_user sprintf "Shall I apply this hunk? (%d/%s)  [%s], or ? for help: ",
            $args{change},
            $args{change_count},
            $args{command_string};

        $c = lc read_key();
        $c = $args{default} if $c eq ' ';

        return $args{commands}->{$c} if exists $args{commands}->{$c};

        to_user "Invalid response, try again!\n";
    }
}

=head2 filter_hunks DIFF

Takes an IncPatch::Diff object and filters out any undesired hunks. Through
the user, of course.

This will return a double of (an arrayref of selected IncPatch::Hunk objects,
an arrayref of unselected IncPatch::Hunk objects).

If you want to override a function so that you can get darcs-record-like
goodness, this is the one. You want to pass in a reference that has a method
C<hunks> that returns an arrayref of hunks. Each hunk is a reference that have
the methods: C<as_string>, C<as_colored_string>, and C<to_file>. C<to_file> is
just the name of the file the hunk is being applied to - it's used in the C<s>
and C<f> commands.

=cut

sub filter_hunks
{
    my $self = shift;
    my $diff = shift;
    my @hunks = @{$diff->hunks};
    my @selected;
    my $i = 0;
    my $suppress_hunk = 0;
    my $commands =
    {
        q => sub { die "User pressed 'q'\n" },
        y => sub { $selected[$i++] = 1 },
        n => sub { $selected[$i++] = 0 },

        d => sub { $i = @hunks },
        a => sub { $selected[$i++] = 1 while $i < @hunks },

        j => sub { $i++ },
        k => sub { $i-- },

        s => sub {
            my $file = $hunks[$i]->to_file;
            $selected[$i] = 0;
            $selected[$i] = 0 while $hunks[++$i]
                                    && $file eq $hunks[$i]->to_file;
        },

        f => sub {
            my $file = $hunks[$i]->to_file;
            $selected[$i] = 1;
            $selected[$i] = 1 while $hunks[++$i]
                                    && $file eq $hunks[$i]->to_file;
        },

        p => sub {
            local $STDOUT = new IO::Pager *STDOUT;
            print $hunks[$i]->as_string;
            close STDOUT;
        },

        e => sub {
            my ($fh, $fn) = solicit("@@ " . $hunks[$i]->lines_affected . " @@\n" . join '', @{$hunks[$i]->lines});
            warn "$Term::CallEditor::errstr\n" and return
                unless $fh;

            # just reading from $fh gets the old text on OS X. ugh
            open my $fh2, '<', $fn
                or do { warn "Unable to open $fn for reading: $!"; return };

            my $affected = <$fh2>;
            $affected =~ s/^\@\@\s*(.+?)\s*\@\@\n?/$1/;
            $hunks[$i]->lines_affected($affected);

            $hunks[$i]->lines( [<$fh2>] );
        },

        '?' => sub {
            $suppress_hunk = 1;
            to_user << "HELP";
COMMANDS
y: apply this hunk
n: don't apply this hunk

f: apply the rest of the hunks to this file
s: don't apply the rest of the hunks to this file

a: apply all the remaining hunks
d: apply selected hunks

j: skip to next hunk
k: back up to previous hunk

p: view this hunk in your pager
e: edit this hunk in your editor

?: show this help

<Space>: accept the current default (which is capitalized)

q: quit IncPatch
HELP
        },
    };

    while ($i < @hunks)
    {
        my $cmd_up = delete $commands->{k};
        $commands->{k} = $cmd_up if $i > 0;

        my $code = prompt_user
        (
            hunk           => $hunks[$i],
            suppress_hunk  => $suppress_hunk,
            change         => $i + 1,
            change_count   => scalar(@hunks),
            default        => $selected[$i] ? 'y' : 'n',
            filter_string  => 1,
            command_string => "ynfsadjkpeq",
            commands       => $commands,
        );

        $commands->{k} = $cmd_up;
        $suppress_hunk = 0;
        $code->();
    }

    # split the hunks into selected and unselected
    my (@s, @u);
    for (0 .. $#selected)
    {
        if ($selected[$_])
        {
            push @s, $hunks[$_];
        }
        else
        {
            push @u, $hunks[$_];
        }
    }

    return (\@s, \@u);
}

1;

