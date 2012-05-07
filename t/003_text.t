use strict;
use warnings;
use Test::More;
use Term::ANSIColor qw(:constants colored);

BEGIN {
	use_ok 'Text::UnicodeBox::Text', qw(:all);
};

my $part = BOX_STRING("Hello world");
isa_ok $part, 'Text::UnicodeBox::Text';
is $part->value, 'Hello world';
is $part->length, length('Hello world');

# align_and_pad

$part->align_and_pad(14);
is $part->value, ' ' . 'Hello world   ' . ' ', "align_and_pad() changes value in place with spaces before and after";

$part = BOX_STRING(45);
$part->align_and_pad(3);
is $part->value, ' '.' 45'.' ', "Numbers are aligned right";

$part = BOX_STRING(72.5);
$part->align_and_pad(5);
is $part->value, ' '.' 72.5'.' ', "Fractional numbers are still numbers";

# Lines

$part = BOX_STRING(
	"This is line one\n".
	"This is line two"
);
my @lines = $part->lines();
is int @lines, 2, "Part split into two lines";
is $part->longest_line_length, 16, "Longest line length";

# Split

$part = BOX_STRING("This is a very long string that needs to be split into multiple parts");

my @segments = $part->split(
	max_width => 20,
	break_words => 1,
);

is_deeply [ map { $_->value } @segments ], [
	'This is a very long ',
	'string that needs to',
	' be split into multi',
	'ple parts',
], "Split max_width => 20, break_words => 1";

# Split with color

$part = BOX_STRING(colored("This is a very long string that needs to be split into multiple parts", 'blue'));

my @char = split //, $part->value;
foreach my $char (@char) {
	print ord($char) . ' ';
}
print "\n";

@segments = $part->split(
	max_width => 20,
	break_words => 1,
);

is_deeply [ map { $_->value } @segments ], [
	BLUE . 'This is a very long ' . RESET,
	BLUE . 'string that needs to' . RESET,
	BLUE . ' be split into multi' . RESET,
	BLUE . 'ple parts' . RESET,
], "Split max_width => 20, break_words => 1";

=cut
12345678901234567890
This is a very long 
string that needs to
 be split into multi
ple parts
=cut

done_testing;

