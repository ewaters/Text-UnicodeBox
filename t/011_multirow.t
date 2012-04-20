use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox';
	use_ok 'Text::UnicodeBox::Control', qw(:all);
};

$Text::UnicodeBox::Utility::report_on_failure = 1;

my $box = Text::UnicodeBox->new(
	whitespace_character => '.',
);
isa_ok $box, 'Text::UnicodeBox';

my @multiline = (
	'While I pondered weak and weary',
	'over many a curious volume of  ',
	'forgotten lore                 '
);

$box->add_line('.', BOX_START( style => 'light', top => 'double' ), " $multiline[0] ", BOX_END(), '.');
$box->add_line('.', BOX_START( style => 'light' ), " $multiline[1] ", BOX_END(), '.');
$box->add_line('.', BOX_START( style => 'light', bottom => 'double' ), " $multiline[2] ", BOX_END(), '.');

is $box->render, <<END_BOX, "Double top/bottom multiline box";
.╒═════════════════════════════════╕.
.│ While I pondered weak and weary │.
.│ over many a curious volume of   │.
.│ forgotten lore                  │.
.╘═════════════════════════════════╛.
END_BOX

# Multi-column and row

$box = Text::UnicodeBox->new(
	whitespace_character => '.',
);

$box->add_line(
	BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ),
	' id ', BOX_RULE, ' ts                  ', BOX_RULE, ' log                 ',
	BOX_END()
);

is $box->render, <<END_BOX, "Multi-column box";
┏━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┓
┃ id ┃ ts                  ┃ log                 ┃
┗━━━━┻━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━┛
END_BOX

# Multi-column and multi-row

$box = Text::UnicodeBox->new(
	whitespace_character => '.',
);

$box->add_line(
	BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ),
	' id ', BOX_RULE, ' ts                  ', BOX_RULE, ' log                 ',
	BOX_END()
);

$box->add_line(
	BOX_START( style => 'light', bottom => 'light' ),
	' 2  ', BOX_RULE, ' 2012-04-16 16:30:43 ', BOX_RULE, ' Eric was here       ',
	BOX_END()
);

is $box->render, <<END_BOX, "Multi-column, multi-row box with separation";
┏━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┓
┃ id ┃ ts                  ┃ log                 ┃
┡━━━━╇━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│ 2  │ 2012-04-16 16:30:43 │ Eric was here       │
└────┴─────────────────────┴─────────────────────┘
END_BOX

done_testing;
