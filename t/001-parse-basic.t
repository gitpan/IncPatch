#!perl -T
use strict;
use warnings;
use Test::More tests => 21;
use IncPatch;
use Scalar::Util 'blessed';

my $text_diff = << 'DIFF';
diff -rN -u old-2.0/lib/Interhack/Plugin/Util/Util.pm new-2.0/lib/Interhack/Plugin/Util/Util.pm
--- old-2.0/lib/Interhack/Plugin/Util/Util.pm	2007-10-27 00:43:33.000000000 -0400
+++ new-2.0/lib/Interhack/Plugin/Util/Util.pm	2007-10-27 00:43:33.000000000 -0400
@@ -3,7 +3,7 @@
 use Calf::Role qw/goto vt_like print_row restore_row force_tab_yn force_tab_ynq 
                   expecting_command extended_command attr_to_ansi/;
 use Term::ReadKey;
-use Time::HiRes 'time';
+use Time::HiRes 'ualarm';
 
 our $VERSION = '1.99_01';
 our $SUMMARY = 'Utility functions for other plugins';
@@ -149,24 +149,14 @@
     my $input = shift;
     my $timeout = shift;
 
-    # ok, so we lied. but only a little.
-    $timeout = 60*60*24*365 if !defined $timeout;
-
     $self->print_row(2, "\e[1;31m$input\e[m");
-    my $start = time;
-
-    while (1)
-    {
-        # have we expired the timeout?
-        my $so_far = time - $start;
-        last if $so_far >= $timeout;
 
-        # wait for however long we have left in the timeout, OR a keypress
-        my $c = ReadKey($timeout - $so_far);
-
-        # pressing tab ends this dance
-        last if $c eq "\t";
-    }
+    eval {
+        ualarm $timeout * 1_000_000 if defined $timeout;
+        1 until ReadKey(0) eq "\t";
+        alarm 0;
+    };
+    alarm 0;
 
     $self->restore_row(2);
 } # }}}

DIFF

my $diff = IncPatch::Diff->new($text_diff);
ok($diff, "IncPatch::Diff->new returned true value");
ok(ref($diff), "IncPatch::Diff->new returned a reference");
ok(blessed($diff), "IncPatch::Diff->new returned a blessed reference");
ok($diff->isa('IncPatch::Diff'), "IncPatch::Diff->new returned a IncPatch::Diff");


my @hunks = @{$diff->hunks};
is(@hunks, 2, "only one hunk in this one");

for my $hunk (@hunks)
{
    is($hunk->diff_invocation, "diff -rN -u old-2.0/lib/Interhack/Plugin/Util/Util.pm new-2.0/lib/Interhack/Plugin/Util/Util.pm", "invocation is correct");
    is($hunk->from_file, "old-2.0/lib/Interhack/Plugin/Util/Util.pm", "correct from file");
    is($hunk->to_file, "new-2.0/lib/Interhack/Plugin/Util/Util.pm", "correct to file");
    is($hunk->from_timestamp, "2007-10-27 00:43:33.000000000 -0400", "correct from timestamp");
    is($hunk->to_timestamp, "2007-10-27 00:43:33.000000000 -0400", "correct to timestamp");
}

is($hunks[0]->lines_affected, "-3,7 +3,7", "correct lines affected");
is($hunks[1]->lines_affected, "-149,24 +149,14", "correct lines affected");
is(@{ $hunks[0]->lines }, 8, "eight lines in first hunk");
is(@{ $hunks[1]->lines }, 31, "31 lines in second hunk");

is($hunks[0]->as_string, <<'HUNK0', 'first hunk correctly passed through');
diff -rN -u old-2.0/lib/Interhack/Plugin/Util/Util.pm new-2.0/lib/Interhack/Plugin/Util/Util.pm
--- old-2.0/lib/Interhack/Plugin/Util/Util.pm	2007-10-27 00:43:33.000000000 -0400
+++ new-2.0/lib/Interhack/Plugin/Util/Util.pm	2007-10-27 00:43:33.000000000 -0400
@@ -3,7 +3,7 @@
 use Calf::Role qw/goto vt_like print_row restore_row force_tab_yn force_tab_ynq 
                   expecting_command extended_command attr_to_ansi/;
 use Term::ReadKey;
-use Time::HiRes 'time';
+use Time::HiRes 'ualarm';
 
 our $VERSION = '1.99_01';
 our $SUMMARY = 'Utility functions for other plugins';
HUNK0

is($hunks[1]->as_string, <<'HUNK1', 'second hunk correctly passed through');
diff -rN -u old-2.0/lib/Interhack/Plugin/Util/Util.pm new-2.0/lib/Interhack/Plugin/Util/Util.pm
--- old-2.0/lib/Interhack/Plugin/Util/Util.pm	2007-10-27 00:43:33.000000000 -0400
+++ new-2.0/lib/Interhack/Plugin/Util/Util.pm	2007-10-27 00:43:33.000000000 -0400
@@ -149,24 +149,14 @@
     my $input = shift;
     my $timeout = shift;
 
-    # ok, so we lied. but only a little.
-    $timeout = 60*60*24*365 if !defined $timeout;
-
     $self->print_row(2, "\e[1;31m$input\e[m");
-    my $start = time;
-
-    while (1)
-    {
-        # have we expired the timeout?
-        my $so_far = time - $start;
-        last if $so_far >= $timeout;
 
-        # wait for however long we have left in the timeout, OR a keypress
-        my $c = ReadKey($timeout - $so_far);
-
-        # pressing tab ends this dance
-        last if $c eq "\t";
-    }
+    eval {
+        ualarm $timeout * 1_000_000 if defined $timeout;
+        1 until ReadKey(0) eq "\t";
+        alarm 0;
+    };
+    alarm 0;
 
     $self->restore_row(2);
 } # }}}

HUNK1
