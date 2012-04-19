package Text::UnicodeBox::Control;

use Moose;
use Text::UnicodeBox::Utility qw(fetch_box_character);
use Exporter 'import';

has 'style'    => ( is => 'rw' );
has 'position' => ( is => 'ro' );
has 'top'      => ( is => 'ro' );
has 'bottom'   => ( is => 'ro' );

our @EXPORT_OK = qw(BOX_START BOX_END);
our %EXPORT_TAGS = ( all => [@EXPORT_OK] );

sub BOX_START {
	return __PACKAGE__->new(position => 'start', @_);
}

sub BOX_END {
	return __PACKAGE__->new(position => 'end', @_);
}

sub to_string {
	my ($self, $context) = @_;

	my $style = $self->style;
	
	if ($self->position eq 'start') {
		$context->{start} = $self;
	}
	elsif ($self->position eq 'end') {
		$context->{end} = $self;
		if (my $start = $context->{start}) {
			$style = $start->style;
			$self->style($style); # Update my own style to the context style
		}
	}

	# Default style to 'light'
	$style ||= 'light';

	return fetch_box_character( vertical => $style );
}

1;
