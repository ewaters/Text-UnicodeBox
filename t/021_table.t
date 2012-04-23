use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox::Table';
};

$Text::UnicodeBox::Utility::report_on_failure = 1;

my $table = Text::UnicodeBox::Table->new();

my @columns = qw(id ts log);
my @rows = (
	[ 1, '2012-04-16 12:34:16', 'blakblkj welkjwe' ],
	[ 2, '2012-04-16 16:30:43', 'Eric was here' ],
	[ 3, '2012-04-16 16:31:43', 'Eric was here again' ],
);

is "\n" . $table->render, <<END_BOX, "Sample MySQL table output";
┏━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┓
┃ id ┃ ts                  ┃ log                 ┃
┡━━━━╇━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│  1 │ 2012-04-16 12:34:16 │ blakblkj welkjwe    │
│  2 │ 2012-04-16 16:30:43 │ Eric was here       │
│  3 │ 2012-04-16 16:31:43 │ Eric was here again │
└────┴─────────────────────┴─────────────────────┘
END_BOX
done_testing;



=cut
╒════╤═════════════════════╤═════════════════════╕
│ id │ ts                  │ log                 │
╞════╪═════════════════════╪═════════════════════╡
│ 1  │ 2012-04-16 12:34:16 │ blakblkj welkjwe    │
│ 2  │ 2012-04-16 16:30:43 │ Eric was here       │
│ 3  │ 2012-04-16 16:31:43 │ Eric was here again │
╘════╧═════════════════════╧═════════════════════╛
=cut
