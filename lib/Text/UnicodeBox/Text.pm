package Text::UnicodeBox::Text;

use Moose;
use Text::UnicodeBox::Utility;
use Text::CharWidth qw(mbswidth);
use Term::ANSIColor qw(colorstrip);
use Exporter 'import';

has 'value'    => ( is => 'ro' );
has 'length'   => ( is => 'ro' );

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

sub to_string {
	my $self = shift;
	return $self->value;
}

1;
