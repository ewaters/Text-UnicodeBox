package Text::UnicodeBox::Text;

=head1 NAME

Text::UnicodeBox::Text - Objects to describe text rendering

=head1 DESCRIPTION

This module is part of the low level interface to L<Text::UnicodeBox>; you probably don't need to use it directly.

=cut

use Moose;
use Text::UnicodeBox::Utility;
use Text::CharWidth qw(mbwidth mbswidth);
use Term::ANSIColor qw(colorstrip);
use Exporter 'import';
use List::Util qw(max);

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
has 'line_count' => ( is => 'rw', default => 1 );
has '_words'   => ( is => 'rw' );
has '_longest_word_length' => ( is => 'rw' );
has '_lines'   => ( is => 'rw' );
has '_longest_line_length' => ( is => 'rw' );

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

=doc _split_up_on_whitespace

Normally we don't need to know the width or location of every word in the string.  If we want to split things on word boundaries, though, let's figure this out and store each word as a separate object.

=cut

sub _split_up_on_whitespace {
	my $self = shift;

	# Don't repeat work
	return if $self->_longest_word_length;

	my (@words, $longest_word);
	foreach my $word (split / /, $self->value) {
		my $obj = BOX_STRING($word);
		push @words, $obj;
		$longest_word = $obj->length if ! $longest_word || $longest_word < $obj->length;
	}
	
	$self->_longest_word_length($longest_word || 0);
	$self->_words(\@words)
}

=head2 lines

Return array of objects of this string split into new strings on the newline character

=cut

sub lines {
	my $self = shift;
	$self->_split_up_on_newline();
	if ($self->_lines) {
		return @{ $self->_lines };
	}
	else {
		return $self;
	}
}

=head2 longest_line_length

Return the length of the longest line in C<lines()>

=cut

sub longest_line_length {
	my $self = shift;
	$self->_split_up_on_newline();
	return $self->_longest_line_length;
}

=doc _split_up_on_newline

Populate _lines, line_count and _longest_line_length

=cut

sub _split_up_on_newline {
	my $self = shift;

	# Don't repeat work
	return if defined $self->_longest_line_length;

	my (@lines, $longest_line);
	foreach my $line (split /\n/, $self->value) {
		my $obj = BOX_STRING($line);
		push @lines, $obj;
		$longest_line = max($obj->length, $longest_line || 0);
	}
	
	$self->_longest_line_length($longest_line || 0);
	$self->_lines(\@lines);
	$self->line_count(int @lines);
}

=doc
[1m bold on (see below)
[22m bold off (see below)
[3m italics on
[23m italics off
[4m underline on
[24m underline off
[7m inverse on; reverses foreground & background colors
[27m inverse off
[9m strikethrough on
[29m strikethrough off
=cut

sub split {
	my ($self, %args) = @_;

	my @segments;
	my $value = $self->value;
	if ($args{break_words}) {
		my $width = 0;
		my $buffer = '';
		my %color_state;
		while (length $value) {
			my $char = substr $value, 0, 1, '';

			# Check for a color escape sequence
			if (ord($char) == 27 && $value =~ m{^\[(\d+)m}) {
				my $color_state = $1 * 1;
				$value =~ s{^\[\d+m}{};
				$buffer .= $char . "[${color_state}m";

				my $type;
				# 0 is the reset code
				if ($color_state == 0) {
					%color_state = ();
				}
				elsif ($color_state == 1 || $color_state == 22) {
					$type = 'bold';
				}
				elsif ($color_state == 3 || $color_state == 23) {
					$type = 'italics';
				}
				elsif ($color_state == 4 || $color_state == 24) {
					$type = 'underline';
				}
				elsif ($color_state == 7 || $color_state == 27) {
					$type = 'inverse';
				}
				elsif ($color_state == 9 || $color_state == 29) {
					$type = 'strikethrough';
				}
				elsif ($color_state >= 30 || $color_state <= 39) {
					$type = 'foreground';
				}
				elsif ($color_state >= 40 || $color_state <= 49) {
					$type = 'background';
				}
				if ($color_state >= 20 && $color_state <= 29) {
					delete $color_state{$type};
				}
				else {
					$color_state{$type} = $color_state;
				}
				next;
			}
			
			my $char_width = mbwidth($char);
			if ($char_width + $width <= $args->{max_width}) {
				$buffer .= $char;
				$width += $char_width;
			}
		}
	}
	else {
		die "Not supported";
	}
	return @segments;
}

=doc _split_to_max_width

This string could contain bytes that span 0, 1 or 2 terminal columns.  Given a max width, split up this string into a number of other strings whose terminal width is no more than the passed width.

=cut

sub _split_to_max_width {
	my ($self, $max_width) = @_;

	my @segments;
	my $value = $self->value;
	while (length $value) {
		my $segment = substr $value, 0, $max_width, '';
		push @segments, BOX_STRING($segment);
	}
	return @segments;
}

=head1 COPYRIGHT

Copyright (c) 2012 Eric Waters and Shutterstock Images (http://shutterstock.com).  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this module.

=head1 AUTHOR

Eric Waters <ewaters@gmail.com>

=cut

1;
