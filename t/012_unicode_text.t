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

my $kanji = " \x{8c61}\x{5f62}\x{6587}\x{5b57}\x{8c61}\x{5f62}\x{6587}\x{5b57} ";
is length($kanji), 10, "Double-width Kanji characters";
is BOX_STRING($kanji)->length, 18, "Width as seen by the module";

$box->add_line(
	'.', BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ),
	$kanji,
	BOX_END(), '.',
);

is $box->render, <<END_BOX, "Box with Kanji unicode text";
.\x{250f}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2513}.
.\x{2503} \x{8c61}\x{5f62}\x{6587}\x{5b57}\x{8c61}\x{5f62}\x{6587}\x{5b57} \x{2503}.
.\x{2517}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{251b}.
END_BOX

# Miscellanous foreign character sets

$box = Text::UnicodeBox->new();
isa_ok $box, 'Text::UnicodeBox';

is BOX_STRING(" suscripci".pack("U", 0xf3)."n  ")->length, 14, "Spanish";
is BOX_STRING(" qualit".pack("U", 0xe9)."      ")->length, 14, "Portuegese";
is BOX_STRING(" \x{444}\x{43e}\x{442}\x{43e}\x{433}\x{440}\x{430}\x{444}\x{438}\x{439}   ")->length, 14, "Russian";
is BOX_STRING(" \x{6536}\x{96c6}\x{5e93}\x{5185}\x{589e}\x{52a0} ")->length, 14, "Chinese";
is BOX_STRING(" \x{5199}\x{771f}\x{306e}\x{8ca9}\x{58f2}\x{30a8} ")->length, 14, "Japanese";

$box->add_line( BOX_START( style => 'heavy', top => 'heavy' ), " suscripci".pack("U", 0xf3)."n  ", BOX_END() );
$box->add_line( BOX_START( style => 'heavy' ),                 " qualit".pack("U", 0xe9)."      ", BOX_END() );
$box->add_line( BOX_START( style => 'heavy' ),                 " \x{444}\x{43e}\x{442}\x{43e}\x{433}\x{440}\x{430}\x{444}\x{438}\x{439}   ", BOX_END() );
$box->add_line( BOX_START( style => 'heavy' ),                 " \x{6536}\x{96c6}\x{5e93}\x{5185}\x{589e}\x{52a0} ", BOX_END() );
$box->add_line( BOX_START(style => 'heavy',bottom => 'heavy'), " \x{5199}\x{771f}\x{306e}\x{8ca9}\x{58f2}\x{30a8} ", BOX_END() );

is $box->render,
"\x{250f}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2513}
\x{2503} suscripci".pack("U", 0xf3)."n  \x{2503}
\x{2503} qualit".pack("U", 0xe9)."      \x{2503}
\x{2503} \x{444}\x{43e}\x{442}\x{43e}\x{433}\x{440}\x{430}\x{444}\x{438}\x{439}   \x{2503}
\x{2503} \x{6536}\x{96c6}\x{5e93}\x{5185}\x{589e}\x{52a0} \x{2503}
\x{2503} \x{5199}\x{771f}\x{306e}\x{8ca9}\x{58f2}\x{30a8} \x{2503}
\x{2517}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{251b}
", "Box with many languages";

done_testing;
