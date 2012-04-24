package Text::UnicodeBox::Table;

use Moose;
use Text::UnicodeBox::Text qw(:all);
use Text::UnicodeBox::Control qw(:all);
extends 'Text::UnicodeBox';

has 'lines'             => ( is => 'rw', default => sub { [] } );
has 'max_column_widths' => ( is => 'rw', default => sub { [] } );

sub add_header {
	my $self = shift;
	my %opt = ref $_[0] ? %{ shift @_ } : ();
	$opt{header} = 1;
	$self->push_line(\%opt, @_);
}

sub add_row {
	my $self = shift;
	my %opt = ref $_[0] ? %{ shift @_ } : ();
	$self->push_line(\%opt, @_);
}

around 'render' => sub {
	my $orig = shift;
	my $self = shift;

	my @lines = @{ $self->lines };
	foreach my $i (0..$#lines) {
		my ($opts, $columns) = @{ $lines[$i] };
		my @parts = (
			BOX_START(
				style => $opts->{style} || 'light',
				($opts->{header} || $i == 0 ? (
				top => $opts->{style} || $opts->{top} || 'light',
				) : ()),
				($opts->{header} || $i == $#lines ? (
				bottom => $opts->{style} || $opts->{bottom} || 'light',
				) : ()),
			)
		);
		foreach my $j (0..$#{$columns}) {
			push @parts, $columns->[$j]->align_and_pad($self->max_column_widths->[$j]);
			if ($j != $#{$columns}) {
				push @parts, BOX_RULE;
			}
			elsif ($j == $#{$columns}) {
				push @parts, BOX_END;
			}
		}
		$self->add_line(@parts);
	}

	$self->$orig();
};

sub push_line {
	my ($self, $opt, @columns) = @_;

	# Convert each column into a ::Text object so that I can figure out the length as
	# well as record max column widths
	my @strings;
	foreach my $i (0..$#columns) {
		my $string = BOX_STRING($columns[$i]);
		push @strings, $string;
		$self->max_column_widths->[$i] = $string->length
			if ! $self->max_column_widths->[$i] || $self->max_column_widths->[$i] < $string->length;
	}

	push @{ $self->lines }, [ $opt, \@strings ];
}

1;
