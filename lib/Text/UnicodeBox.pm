package Text::UnicodeBox;

use Moose;

use Text::UnicodeBox::Control qw(:all);
use Text::UnicodeBox::Text qw(:all);
use Scalar::Util qw(blessed);

has 'buffer_ref' => ( is => 'rw', default => sub { my $buffer = '';  return \$buffer } );

sub buffer {
	my $self = shift;
	return ${ $self->buffer_ref };
}

sub add_line {
	my $self = shift;
	my @parts;

	# Read off each arg, validate, then push onto @parts as objects
	foreach my $part (@_) {
		if (ref $part && blessed $part && ($part->isa('Text::UnicodeBox::Control') || $part->isa('Text::UnicodeBox::Text'))) {
			push @parts, $part;
		}
		elsif (ref $part) {
			die "add_line() takes only strings or Text::UnicodeBox:: objects as arguments";
		}
		else {
			push @parts, STRING($part);
		}
	}

	# Generate this line as text
	my $line = '';
	my %context;
	foreach my $part (@parts) {
		$line .= $part->to_string(\%context);
	}
	$line .= "\n";

	# Add lines to the buffer ref
	my $buffer_ref = $self->buffer_ref;
	$$buffer_ref .= $line;
}

1;
