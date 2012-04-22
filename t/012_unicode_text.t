use strict;
use warnings;
use utf8;
use Test::More;
use Encode qw(encode decode);

BEGIN {
	use_ok 'Text::UnicodeBox';
	use_ok 'Text::UnicodeBox::Control', qw(:all);
	use_ok 'Text::UnicodeBox::Text', qw(:all);
};

my $box = Text::UnicodeBox->new(
	whitespace_character => '.',
);
isa_ok $box, 'Text::UnicodeBox';

my $kanji = ' 象形文字象形文字 ';
is length($kanji), 10, "Double-width Kanji characters";
is BOX_STRING($kanji)->length, 18, "Width as seen by the module";

$box->add_line(
	'.', BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ),
	$kanji,
	BOX_END(), '.',
);

is $box->render, <<END_BOX, "Box with Kanji unicode text";
.┏━━━━━━━━━━━━━━━━━━┓.
.┃ 象形文字象形文字 ┃.
.┗━━━━━━━━━━━━━━━━━━┛.
END_BOX

done_testing;
