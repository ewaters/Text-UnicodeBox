use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox::Table';
};

$Text::UnicodeBox::Utility::report_on_failure = 1;

my @columns = qw(id ts log);
my @rows = (
	[ 1, '2012-04-16 12:34:16', 'blakblkj welkjwe' ],
	[ 2, '2012-04-16 16:30:43', 'Eric was here' ],
	[ 3, '2012-04-16 16:31:43', 'Eric was here again' ],
);

my $table = Text::UnicodeBox::Table->new();
isa_ok $table, 'Text::UnicodeBox::Table';

$table->add_header({ style => 'heavy' }, @columns);
$table->add_row(@$_) foreach @rows;

is "\n" . $table->render, <<END_BOX, "Sample MySQL table output";

┏━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┓
┃ id ┃ ts                  ┃ log                 ┃
┡━━━━╇━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━┩
│  1 │ 2012-04-16 12:34:16 │ blakblkj welkjwe    │
│  2 │ 2012-04-16 16:30:43 │ Eric was here       │
│  3 │ 2012-04-16 16:31:43 │ Eric was here again │
└────┴─────────────────────┴─────────────────────┘
END_BOX

$table = Text::UnicodeBox::Table->new();

$table->add_header({ top => 'double', bottom => 'double' }, @columns);
$table->add_row(@{ $rows[0] });
$table->add_row(@{ $rows[1] });
$table->add_row({ bottom => 'double' }, @{ $rows[2] });

is "\n" . $table->render, <<END_BOX, "Different take on the rendering";

╒════╤═════════════════════╤═════════════════════╕
│ id │ ts                  │ log                 │
╞════╪═════════════════════╪═════════════════════╡
│  1 │ 2012-04-16 12:34:16 │ blakblkj welkjwe    │
│  2 │ 2012-04-16 16:30:43 │ Eric was here       │
│  3 │ 2012-04-16 16:31:43 │ Eric was here again │
╘════╧═════════════════════╧═════════════════════╛
END_BOX

done_testing;
