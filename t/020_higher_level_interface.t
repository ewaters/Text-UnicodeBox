use strict;
use warnings;
use utf8;
use Test::More;
use Text::ASCIITable;

BEGIN {
	use_ok 'Text::UnicodeBox::ASCIITable';
};

# Demonstrate that Text::ASCIITable does what it's reported to do
{
	my $t = Text::ASCIITable->new({ headingText => 'Basket' });

	$t->setCols('Id','Name','Price');
	$t->addRow(1,'Dummy product 1',24.4);
	$t->addRow(2,'Dummy product 2',21.2);
	$t->addRow(3,'Dummy product 3',12.3);
	$t->addRowLine();
	$t->addRow('','Total',57.9);

	is ''.$t, <<END_TABLE, "Text::ASCIITable test from cpan";
.------------------------------.
|            Basket            |
+----+-----------------+-------+
| Id | Name            | Price |
+----+-----------------+-------+
|  1 | Dummy product 1 |  24.4 |
|  2 | Dummy product 2 |  21.2 |
|  3 | Dummy product 3 |  12.3 |
+----+-----------------+-------+
|    | Total           |  57.9 |
'----+-----------------+-------'
END_TABLE
}

# Now let's prove that we can do the same thing but with unicode box characters
{
	my $t = Text::UnicodeBox::ASCIITable->new({ headingText => 'Basket' });
	isa_ok $t, 'Text::UnicodeBox::ASCIITable';

	$t->setCols('Id','Name','Price');
	$t->addRow(1,'Dummy product 1',24.4);
	$t->addRow(2,'Dummy product 2',21.2);
	$t->addRow(3,'Dummy product 3',12.3);
	$t->addRowLine();
	$t->addRow('','Total',57.9);

	is ''.$t, <<END_TABLE, "Text::UnicodeBox::ASCIITable produces similar but prettier results";
.------------------------------.
|            Basket            |
+----+-----------------+-------+
| Id | Name            | Price |
+----+-----------------+-------+
|  1 | Dummy product 1 |  24.4 |
|  2 | Dummy product 2 |  21.2 |
|  3 | Dummy product 3 |  12.3 |
+----+-----------------+-------+
|    | Total           |  57.9 |
'----+-----------------+-------'
END_TABLE
}

done_testing;
