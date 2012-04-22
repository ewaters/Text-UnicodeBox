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

done_testing;

