#!perl -T
use strict;
use warnings;
use Test::More tests => 2;
use IncPatch;

# setup and helper functions {{{
{
    package FakeHunk;
    sub as_string { "FakeHunk->as_string" }
    sub as_colored_string { "FakeHunk->as_colored_string" }
}
my $hunk = 'FakeHunk';

no warnings 'redefine';

my @keys;
*IncPatch::UI::read_key = sub
{
    return shift @keys;
};

my $output;
*IncPatch::UI::to_user = sub
{
    $output .= join '', @_;
};

sub type { push @keys, split '', join '', @_ }

my %typed;
my %commands = ( map { my $c = $_; $c => sub { $typed{$c}++ } }
                 qw/? a b c q x y z/ );

my %defaults = (hunk => $hunk, commands => \%commands, change => 3);
sub t
{
    my %args = @_;

    @keys = delete $args{type} if exists $args{type};

    my $sub = IncPatch::UI::prompt_user(%defaults, %args);
    $sub->();
    my $ret = join '', grep { length } map { $_ x $typed{$_} } keys %typed;
    %typed = ();
    return $ret;
};
# }}}

is(t(type => "x"), "x");
$output .= "\n"; # easier than chomping a heredoc
is($output, << "EXPECTED", "output matches exactly");
FakeHunk->as_colored_string
Shall I apply this hunk? (3/?)  [abcqxyz], or ? for help: 
EXPECTED

