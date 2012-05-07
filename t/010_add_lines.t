use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox';
	use_ok 'Text::UnicodeBox::Control', qw(:all);
};

my $box = Text::UnicodeBox->new(
	whitespace_character => '.',
);
isa_ok $box, 'Text::UnicodeBox';

$box->add_line(
	'.', BOX_START( style => 'heavy', top => 'heavy', bottom => 'heavy' ), ' This is a header ', BOX_END(), '.',
);

is $box->buffer, <<END_BOX, "Buffer has an interim state";
.\x{250f}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2513}.
.\x{2503} This is a header \x{2503}.
END_BOX

is $box->render, <<END_BOX, "Render completes the box";
.\x{250f}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2513}.
.\x{2503} This is a header \x{2503}.
.\x{2517}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{2501}\x{251b}.
END_BOX

done_testing;
