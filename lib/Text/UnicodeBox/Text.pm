package Text::UnicodeBox::Text;

use Moose;
use Text::UnicodeBox::Utility;
use Encode qw(encode);
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

	# Some characters (Kanji, for instance) take up two columns per character
	my $length = length(encode('big5', $stripped_string));

	return __PACKAGE__->new(value => $string, length => $length);
}

sub to_string {
	my $self = shift;
	return $self->value;
}

1;
