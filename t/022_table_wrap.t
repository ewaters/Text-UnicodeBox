use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
	use_ok 'Text::UnicodeBox::Table';
};

$Text::UnicodeBox::Utility::report_on_failure = 1;

my @columns = qw(name quote);
my @rows = (
	[
		"Edward R. Murrow\n".
		"  Journalist",
		"To be persuasive we must be believable;\n".
		"to be believable we must be creditable;\n".
		"to be credible we must be truthful.",
	],
	[
		"Mahatma Gandhi",
		"The greatness of a nation and its moral progress can be judged by the way its animals are treated.",
	],
);

## split_lines = 1

my $table = Text::UnicodeBox::Table->new( split_lines => 1 );
isa_ok $table, 'Text::UnicodeBox::Table';

$table->add_header({ style => 'heavy' }, @columns);
$table->add_row(@$_) foreach @rows;

is "\n" . $table->render, <<END_BOX, "Split lines";

┏━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ name             ┃ quote                                                                                              ┃
┡━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ Edward R. Murrow │ To be persuasive we must be believable;                                                            │
│   Journalist     │ to be believable we must be creditable;                                                            │
│                  │ to be credible we must be truthful.                                                                │
│ Mahatma Gandhi   │ The greatness of a nation and its moral progress can be judged by the way its animals are treated. │
└──────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────┘
END_BOX

## 

$table = Text::UnicodeBox::Table->new( split_lines => 1, wrap_cells => 1, max_width => 75 );
isa_ok $table, 'Text::UnicodeBox::Table';

$table->add_header({ style => 'heavy' }, @columns);
$table->add_row(@$_) foreach @rows;

is "\n" . $table->render, <<END_BOX, "Split lines, wrap cells";

┏━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ name             ┃ quote                                                ┃
┡━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ Edward R. Murrow │ To be persuasive we must be believable;              │
│   Journalist     │ to be believable we must be creditable;              │
│                  │ to be credible we must be truthful.                  │
│ Mahatma Gandhi   │ The greatness of a nation and its moral progress can │
│                  │ be judged by the way its animals are treated.        │
└──────────────────┴──────────────────────────────────────────────────────┘
END_BOX

done_testing;
