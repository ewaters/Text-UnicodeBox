package Text::UnicodeBox::Text;

=head1 NAME

Text::UnicodeBox::Text - Objects to describe text rendering

=head1 DESCRIPTION

This module is part of the low level interface to L<Text::UnicodeBox>; you probably don't need to use it directly.

=cut

use Moose;
use Text::UnicodeBox::Utility;
use Text::CharWidth qw(mbswidth);
use Term::ANSIColor qw(colorstrip);
use Exporter 'import';

=head1 METHODS

=head2 new (%params)

=over 4

=item value

The string representation of the text.

=item length

How many characters wide the text represents when rendered on the screen.

=back

=cut

has 'value'    => ( is => 'rw' );
has 'length'   => ( is => 'rw' );

our @EXPORT_OK = qw(BOX_STRING);
our %EXPORT_TAGS = ( all => [@EXPORT_OK] );

=head1 EXPORTED METHODS

The following methods are exportable by name or by the tag ':all'

=head2 BOX_STRING ($value)

Given the passed text, figures out the a smart value for the C<length> field and returns a new instance.

=cut

sub BOX_STRING {
	my $string = shift;

	# Strip out any colors
	my $stripped_string = colorstrip($string);

	# Determine the width on a terminal of the string given; may be composed of unicode characters that take up two columns, or by ones taking up 0 columns
	my $length = mbswidth($stripped_string);

	return __PACKAGE__->new(value => $string, length => $length);
}

=head2 align_and_pad

  my $text = BOX_STRING('Test');
  $text->align_and_pad(8);
  # is the same as
  # $text->align_and_pad( width => 8, pad => 1, pad_char => ' ', align => 'left' );
  $text->value eq ' Test     ';

Modify the value of this object to pad and align the text according to the specification.  Pass any of the following parameters:

=over 4

=item width

Defaults to the object's C<length>.  Specifies how wide of a space the string is to be fit in.  Doesn't make sense for this value to smaller then the width of the string.  If you pass only one parameter to C<align_and_pad>, this is the parameter it's assigned to.

=item align

If the string looks like a number, the align default to 'right'; otherwise, 'left'.

=item pad (default: 1)

How much padding on the right and left

=item pad_char (default: ' ')

What character to use for padding

=back

=cut

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

=head2 to_string

Returns the value of this object.

=cut

sub to_string {
	my $self = shift;
	return $self->value;
}

=head1 COPYRIGHT

Copyright (c) 2012 Eric Waters and Shutterstock Images (http://shutterstock.com).  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this module.

=head1 AUTHOR

Eric Waters <ewaters@gmail.com>

=cut

1;
