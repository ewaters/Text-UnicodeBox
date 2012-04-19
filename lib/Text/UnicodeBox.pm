package Text::UnicodeBox;

use Moose;

use Text::UnicodeBox::Control qw(:all);
use Text::UnicodeBox::Text qw(:all);
use Text::UnicodeBox::Utility qw(fetch_box_character);
use Scalar::Util qw(blessed);

has 'buffer_ref' => ( is => 'rw', default => sub { my $buffer = '';  return \$buffer } );
has 'last_line'  => ( is => 'rw' );

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

	## Generate the previous line if needed

	my $previous_line;
	my @box_tops = grep { $_->can('top') && $_->top } @parts;
	if (@box_tops) {
		my $in_box_style;
		$previous_line = '';
		foreach my $part (@parts) {
			if ($part->isa('Text::UnicodeBox::Text')) {
				my $char = $in_box_style ? fetch_box_character( horizontal => $in_box_style ) : ' ';
				$previous_line .= $char x $part->length;
			}
			elsif ($part->isa('Text::UnicodeBox::Control')) {
				if ($part->position eq 'start' && $part->top) {
					$in_box_style = $part->top;
					$previous_line .= fetch_box_character( down => ($part->style || 'light'), right => $in_box_style );
				}
				elsif ($part->position eq 'end') {
					$previous_line .= fetch_box_character( down => ($part->style || 'light'), left => $in_box_style );
					$in_box_style = undef;
				}
			}
		}
		$previous_line .= "\n";
	}

	# Store this for later reference
	$self->last_line({ parts => \@parts, line => $line });

	# Add lines to the buffer ref
	my $buffer_ref = $self->buffer_ref;
	$$buffer_ref .= $previous_line if defined $previous_line;
	$$buffer_ref .= $line;
}

sub render {
	my $self = shift;

	return $self->buffer();
}

1;
