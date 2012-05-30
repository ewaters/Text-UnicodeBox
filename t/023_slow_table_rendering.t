use strict;
use warnings;
use utf8;
use Test::More;
use FindBin;
use Time::HiRes qw(gettimeofday);
use Benchmark qw(:all);

BEGIN {
	use_ok 'Text::UnicodeBox::Table';
};

$Text::UnicodeBox::Utility::report_on_failure = 1;

# Load data from file

my (@columns, @rows);
{
	my $data = do $FindBin::Bin . '/data/films.dumper';
	foreach my $row (@$data) {
		if (! @columns) {
			@columns = keys %$row;
		}
		my @row;
		@row[ 0..$#columns ] = @{ $row }{ @columns };
		push @rows, \@row;
	}
}

timethese(1, {
	'Normal' => sub {
		my $table = Text::UnicodeBox::Table->new( split_lines => 1 );
		$table->add_header({ style => 'heavy' }, @columns);
		$table->add_row(@$_) foreach @rows;
		my $output = $table->render();
	},
});

done_testing;
