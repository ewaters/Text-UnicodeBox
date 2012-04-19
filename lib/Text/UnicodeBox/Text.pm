package Text::UnicodeBox::Text;

use Moose;
use Text::UnicodeBox::Utility;
use Exporter 'import';

has 'value'    => ( is => 'ro' );
has 'length'   => ( is => 'ro' );

our @EXPORT_OK = qw(STRING);
our %EXPORT_TAGS = ( all => [@EXPORT_OK] );

sub STRING {
	return __PACKAGE__->new(value => $_[0], length => length $_[0]);
}

sub to_string {
	my $self = shift;
	return $self->value;
}

1;
