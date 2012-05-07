use strict;
use warnings;
use Test::More;
use Term::ANSIColor qw(:constants colored);
use Data::Dumper;
use utf8;

BEGIN {
	use_ok 'Text::UnicodeBox::Text', qw(:all);
};

my $part = BOX_STRING("Hello world");
isa_ok $part, 'Text::UnicodeBox::Text';
is $part->value, 'Hello world';
is $part->length, length('Hello world');

## align_and_pad

$part->align_and_pad(14);
is $part->value, ' ' . 'Hello world   ' . ' ', "align_and_pad() changes value in place with spaces before and after";

$part = BOX_STRING(45);
$part->align_and_pad(3);
is $part->value, ' '.' 45'.' ', "Numbers are aligned right";

$part = BOX_STRING(72.5);
$part->align_and_pad(5);
is $part->value, ' '.' 72.5'.' ', "Fractional numbers are still numbers";

## Lines

$part = BOX_STRING(
	"This is line one\n".
	"This is line two"
);
my @lines = $part->lines();
is int @lines, 2, "Part split into two lines";
is $part->longest_line_length, 16, "Longest line length";

## Split

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

## Split with color

$part = BOX_STRING(colored("This is a very long string that needs to be split into multiple parts", 'blue'));

@segments = $part->split(
	max_width => 20,
	break_words => 1,
);

is_deeply [ map { $_->value } @segments ], [
	BLUE . 'This is a very long ' . RESET,
	BLUE . 'string that needs to' . RESET,
	BLUE . ' be split into multi' . RESET,
	BLUE . 'ple parts' . RESET,
], "Split max_width => 20, break_words => 1, all one color";

## More complex styling

$part = BOX_STRING(
	colored("This is a very long ", 'blue') .
	colored("string", 'bold') .
	colored(" that needs to be split into ", 'blue') .
	colored("multiple parts", 'on_blue')
);

@segments = $part->split(
	max_width => 20,
	break_words => 1,
);

is_deeply [ map { $_->value } @segments ], [
	BLUE . 'This is a very long ' . RESET,
	BOLD . 'string' . RESET . BLUE . ' that needs to' . RESET,
	BLUE . ' be split into ' . RESET . ON_BLUE . 'multi' . RESET,
	ON_BLUE . 'ple parts' . RESET,
], "Split max_width => 20, break_words => 1, various colors and styles";

## Split without breaking words

$part = BOX_STRING("This is a very long string that needs to be split into multiple parts");

@segments = $part->split(
	max_width => 20,
);

is_deeply [ map { $_->value } @segments ], [
	'This is a very long ',
	'string that needs to',
	' be split into ',
	'multiple parts',
], "Split max_width => 20, break_words => 0";

## Split without breaking words with color

$part = BOX_STRING(colored("This is a very long string that needs to be split into multiple parts", "blue"));

@segments = $part->split(
	max_width => 20,
);

is_deeply [ map { $_->value } @segments ], [
	BLUE . 'This is a very long ' . RESET,
	BLUE . 'string that needs to' . RESET,
	BLUE . ' be split into ' . RESET,
	BLUE . 'multiple parts' . RESET,
], "Split max_width => 20, break_words => 0, all one color";

## Split unicode text

# "I Can Eat Glass" from http://www.columbia.edu/~fdc/utf8/
my $text = <<ENDTEXT;
\x{39c}\x{3c0}\x{3bf}\x{3c1}\x{3ce} \x{3bd}\x{3b1} \x{3c6}\x{3ac}\x{3c9} \x{3c3}\x{3c0}\x{3b1}\x{3c3}\x{3bc}\x{3ad}\x{3bd}\x{3b1} \x{3b3}\x{3c5}\x{3b1}\x{3bb}\x{3b9}\x{3ac} \x{3c7}\x{3c9}\x{3c1}\x{3af}\x{3c2} \x{3bd}\x{3b1} \x{3c0}\x{3ac}\x{3b8}\x{3c9} \x{3c4}\x{3af}\x{3c0}\x{3bf}\x{3c4}\x{3b1}.
\x{79c1}\x{306f}\x{30ac}\x{30e9}\x{30b9}\x{3092}\x{98df}\x{3079}\x{3089}\x{308c}\x{307e}\x{3059}\x{3002}\x{305d}\x{308c}\x{306f}\x{79c1}\x{3092}\x{50b7}\x{3064}\x{3051}\x{307e}\x{305b}\x{3093}\x{3002}
\x{6211}\x{80fd}\x{541e}\x{4e0b}\x{73bb}\x{7483}\x{800c}\x{4e0d}\x{4f24}\x{8eab}\x{4f53}\x{3002}
\x{16c1}\x{16b3}\x{16eb}\x{16d7}\x{16a8}\x{16b7}\x{16eb}\x{16b7}\x{16da}\x{16a8}\x{16cb}\x{16eb}\x{16d6}\x{16a9}\x{16cf}\x{16aa}\x{16be}\x{16eb}\x{16a9}\x{16be}\x{16de}\x{16eb}\x{16bb}\x{16c1}\x{16cf}\x{16eb}\x{16be}\x{16d6}\x{16eb}\x{16bb}\x{16d6}\x{16aa}\x{16b1}\x{16d7}\x{16c1}\x{16aa}\x{16a7}\x{16eb}\x{16d7}\x{16d6}\x{16ec}
\x{42f} \x{43c}\x{43e}\x{433}\x{443} \x{435}\x{441}\x{442}\x{44c} \x{441}\x{442}\x{435}\x{43a}\x{43b}\x{43e}, \x{43e}\x{43d}\x{43e} \x{43c}\x{43d}\x{435} \x{43d}\x{435} \x{432}\x{440}\x{435}\x{434}\x{438}\x{442}.
\x{b098}\x{b294} \x{c720}\x{b9ac}\x{b97c} \x{ba39}\x{c744} \x{c218} \x{c788}\x{c5b4}\x{c694}. \x{adf8}\x{b798}\x{b3c4} \x{c544}\x{d504}\x{c9c0} \x{c54a}\x{c544}\x{c694}
ENDTEXT

$part = BOX_STRING($text);

@lines = $part->lines();
is int @lines, 6, "Got six lines from 'I Can Eat Glass'";

my @got;
foreach my $line (@lines) {
	my @segment_values;
	foreach my $segment ($line->split( max_width => 20, break_words => 1 )) {
		push @segment_values, $segment->value;
	}
	push @got, \@segment_values;
}

is_deeply
	\@got,
	[
		[
			"\x{39c}\x{3c0}\x{3bf}\x{3c1}\x{3ce} \x{3bd}\x{3b1} \x{3c6}\x{3ac}\x{3c9} \x{3c3}\x{3c0}\x{3b1}\x{3c3}\x{3bc}\x{3ad}\x{3bd}",
			"\x{3b1} \x{3b3}\x{3c5}\x{3b1}\x{3bb}\x{3b9}\x{3ac} \x{3c7}\x{3c9}\x{3c1}\x{3af}\x{3c2} \x{3bd}\x{3b1} \x{3c0}\x{3ac}",
			"\x{3b8}\x{3c9} \x{3c4}\x{3af}\x{3c0}\x{3bf}\x{3c4}\x{3b1}.",
		],
		[
			"\x{79c1}\x{306f}\x{30ac}\x{30e9}\x{30b9}\x{3092}\x{98df}\x{3079}\x{3089}\x{308c}",
			"\x{307e}\x{3059}\x{3002}\x{305d}\x{308c}\x{306f}\x{79c1}\x{3092}\x{50b7}\x{3064}",
			"\x{3051}\x{307e}\x{305b}\x{3093}\x{3002}",
		],
		[
			"\x{6211}\x{80fd}\x{541e}\x{4e0b}\x{73bb}\x{7483}\x{800c}\x{4e0d}\x{4f24}\x{8eab}",
			"\x{4f53}\x{3002}",
		],
		[
			"\x{16c1}\x{16b3}\x{16eb}\x{16d7}\x{16a8}\x{16b7}\x{16eb}\x{16b7}\x{16da}\x{16a8}\x{16cb}\x{16eb}\x{16d6}\x{16a9}\x{16cf}\x{16aa}\x{16be}\x{16eb}\x{16a9}\x{16be}",
			"\x{16de}\x{16eb}\x{16bb}\x{16c1}\x{16cf}\x{16eb}\x{16be}\x{16d6}\x{16eb}\x{16bb}\x{16d6}\x{16aa}\x{16b1}\x{16d7}\x{16c1}\x{16aa}\x{16a7}\x{16eb}\x{16d7}\x{16d6}",
			"\x{16ec}",
		],
		[
			"\x{42f} \x{43c}\x{43e}\x{433}\x{443} \x{435}\x{441}\x{442}\x{44c} \x{441}\x{442}\x{435}\x{43a}\x{43b}\x{43e}, ",
			"\x{43e}\x{43d}\x{43e} \x{43c}\x{43d}\x{435} \x{43d}\x{435} \x{432}\x{440}\x{435}\x{434}\x{438}\x{442}.",
		],
		[
			"\x{b098}\x{b294} \x{c720}\x{b9ac}\x{b97c} \x{ba39}\x{c744} \x{c218} ",
			"\x{c788}\x{c5b4}\x{c694}. \x{adf8}\x{b798}\x{b3c4} \x{c544}\x{d504}",
			"\x{c9c0} \x{c54a}\x{c544}\x{c694}",
		],
	],
	"Split six lines of 'I Can Eat Glass' at 20 width";

done_testing;

sub print_segments {
	my @segments = @_;
	foreach my $segment (@segments) {
		foreach my $char (split //, $segment->value) {
			if (ord($char) == 27) {
				print '^';
			}
			else {
				print $char;
			}
		}
		print "\n";
	}
}

