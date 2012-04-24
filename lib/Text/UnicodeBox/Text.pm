package Text::UnicodeBox::Text;

use Moose;
use Text::UnicodeBox::Utility;
use Text::CharWidth qw(mbswidth);
use Term::ANSIColor qw(colorstrip);
use Exporter 'import';

has 'value'    => ( is => 'rw' );
has 'length'   => ( is => 'rw' );

our @EXPORT_OK = qw(BOX_STRING);
our %EXPORT_TAGS = ( all => [@EXPORT_OK] );

sub BOX_STRING {
	my $string = shift;

	# Strip out any colors
	my $stripped_string = colorstrip($string);

	# Determine the width on a terminal of the string given; may be composed of unicode characters that take up two columns, or by ones taking up 0 columns
	my $length = mbswidth($stripped_string);

	return __PACKAGE__->new(value => $string, length => $length);
}

sub align_and_pad {
	my $self = shift;
	my %opt;
	if (int @_ == 1) {
		$opt{width} = shift;
	}
	else {
		%opt = @_;
	}

	my $string = $self->value();
	my $length = $self->length();

	$opt{width} ||= $length;
	$opt{pad}   = 1 if ! defined $opt{pad};
	$opt{pad_char} ||= ' ';
	if (! $opt{align}) {
		# Align numbers to the right and text to the left
		my $is_a_number = $string =~ m{^([0-9]+|[0-9]*\.[0-9]+)$};
		$opt{align} = $is_a_number ? 'right' : 'left';
	}

	# Align
	while ($length < $opt{width}) {
		$string = $opt{align} eq 'right' ? $opt{pad_char} . $string : $string . $opt{pad_char};
		$length++;
	}
	
	# Pad
	$string = ($opt{pad_char} x $opt{pad}) . $string . ($opt{pad_char} x $opt{pad});
	$length += $opt{pad} * 2;

	$self->value($string);
	$self->length($length);

	return $self;
}

sub to_string {
	my $self = shift;
	return $self->value;
}

1;
