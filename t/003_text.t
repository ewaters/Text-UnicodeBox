use strict;
use warnings;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox::Text', qw(:all);
};

my $part = BOX_STRING("Hello world");
isa_ok $part, 'Text::UnicodeBox::Text';
is $part->value, 'Hello world';
is $part->length, length('Hello world');

$part->align_and_pad(14);
is $part->value, ' ' . 'Hello world   ' . ' ', "align_and_pad() changes value in place with spaces before and after";

$part = BOX_STRING(45);
$part->align_and_pad(3);
is $part->value, ' '.' 45'.' ', "Numbers are aligned right";

$part = BOX_STRING(72.5);
$part->align_and_pad(5);
is $part->value, ' '.' 72.5'.' ', "Fractional numbers are still numbers";

done_testing;

