
use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox';
	use_ok 'Text::UnicodeBox::Control', qw(:all);
};

$Text::UnicodeBox::Utility::report_on_failure = 1;

my $box = Text::UnicodeBox->new();

$box->add_line(
	BOX_START( style => 'double', top => 'double', bottom => 'double' ), '   ', BOX_END(),
	'    ',
	BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ), '   ', BOX_END()
);

$box->add_line(
	'     ',
	BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ), '   ', BOX_END(),
	'   ',
	BOX_START( style => 'light', top => 'light', bottom => 'light' ), '   ', BOX_END(),
);

$box->add_line(
	'  ', BOX_START( style => 'light', top => 'heavy' ), '    ', BOX_END()
);
$box->add_line(
	'  ', BOX_START( style => 'light', bottom => 'heavy' ), '    ', BOX_END()
);

is "\n" . $box->render, <<END_BOX, "Multiple boxes per line with many different styles";

\x{2554}\x{2550}\x{2550}\x{2550}\x{2557}    \x{250f}\x{2501}\x{2501}\x{2501}\x{2513}
\x{2551}   \x{2551}    \x{2503}   \x{2503}
\x{255a}\x{2550}\x{2550}\x{2550}\x{255d}\x{250f}\x{2501}\x{2501}\x{2501}\x{254b}\x{2501}\x{2501}\x{2501}\x{2543}\x{2500}\x{2500}\x{2500}\x{2510}
     \x{2503}   \x{2503}   \x{2502}   \x{2502}
  \x{250d}\x{2501}\x{2501}\x{253b}\x{2501}\x{252f}\x{2501}\x{251b}   \x{2514}\x{2500}\x{2500}\x{2500}\x{2518}
  \x{2502}    \x{2502}
  \x{2502}    \x{2502}
  \x{2515}\x{2501}\x{2501}\x{2501}\x{2501}\x{2519}
END_BOX

done_testing;
