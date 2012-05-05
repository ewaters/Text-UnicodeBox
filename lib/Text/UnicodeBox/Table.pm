package Text::UnicodeBox::Table;

=encoding utf-8

=head1 NAME

Text::UnicodeBox::Table - High level interface providing easy table drawing

=head1 SYNOPSIS

  my $table = Text::UnicodeBox::Table->new();

  $table->add_header('id', 'name');
  $table->add_row('1', 'George Washington');
  $table->add_row('2', 'Thomas Jefferson');
  print $table->render();

  # Prints:
  # ┌────┬───────────────────┐
  # │ id │ name              │
  # ├────┼───────────────────┤
  # │  1 │ George Washington │
  # │  2 │ Thomas Jefferson  │
  # └────┴───────────────────┘

=head1 DESCRIPTION

This module provides an easy high level interface over L<Text::UnicodeBox>.

=cut

use Moose;
use Text::UnicodeBox::Text qw(:all);
use Text::UnicodeBox::Control qw(:all);
use List::Util qw(sum max);
extends 'Text::UnicodeBox';

has 'lines'             => ( is => 'rw', default => sub { [] } );
has 'max_column_widths' => ( is => 'rw', default => sub { [] } );
has 'style'             => ( is => 'rw', default => 'light' );
has 'is_rendered'       => ( is => 'rw' );
has 'split_lines'       => ( is => 'ro' );
has 'max_width'         => ( is => 'ro' );
has 'column_widths'     => ( is => 'rw' );

=head1 METHODS

=head2 new

=over 4

=item style

  my $table = Text::UnicodeBox::Table->new( style => 'horizontal_double ');

You may specify a certain style for the table to be drawn.  This may be overridden on a per row basis.

=item split_lines

If set, line breaks in cell data will result in new rows rather then breaks in the rendering.

=item max_width

If set, the width of the table will ever exceed the given width.  Data will attempted to be split on spaces but will be hyphenated if that's not possible.

=over 4

=item light

All lines are light.

=item heavy

All lines are heavy.

=item double

All lines are double.

=item horizontal_double

All horizontal lines are double, where vertical lines are single.

=item heavy_header

The lines drawing the header are heavy, all others are light.

=back

=back

=head2 add_header ( [\%opt,] @parts )

  $table->add_header({ bottom => 'heavy' }, 'Name', 'Age', 'Address');

Same as C<add_row> but sets the option ('header' => 1)

Draws one line of output with a border on the top and bottom.

=head2 add_row ( [\%opt,] @parts )

If the first argument to this method is a hashref, it is interpreted as an options hash.   This hash takes the following parameters:

=over 4

=item style (default: 'light')

What style will be used for all box characters involved in this line of output.  Options are: 'light', 'double', 'heavy'

=item alignment

  alignment => [ 'right', 'left', 'right' ]
 
Pass a list of 'right' and 'left', corresponding with the number of columns of output.  This will control the alignment of this row, and if passed to C<add_header>, all following rows as well.  By default, values looking like a number are aligned to the right, with all other values aligned to the left.

=item header_alignment

The header will always be aligned to the left unless you pass this array ref to specify custom alignment.

=item top

=item bottom

If set, draw a line above or below the current line.

=item header

Same as passing C<top> and C<bottom> to the given style (or the default style C<style>)

=back

=cut

sub add_header {
	my $self = shift;
	my %opt = ref $_[0] ? %{ shift @_ } : ();
	$opt{header} = 1;

	# Support special table-wide styles
	if ($self->style) {
		if ($self->style eq 'horizontal_double') {
			$opt{bottom} = $opt{top} = 'double';
		}
		elsif ($self->style eq 'heavy_header') {
			$opt{bottom} = $opt{top} = $opt{style} = 'heavy';
		}
		else {
			$opt{style} ||= $self->style;
		}
	}

	$self->_push_line(\%opt, @_);
}

sub add_row {
	my $self = shift;
	my %opt = ref $_[0] ? %{ shift @_ } : ();

	# Support special table-wide styles
	if ($self->style && $self->style =~ m{^(heavy|double|light)$}) {
		$opt{style} = $self->style;
	}

	$self->_push_line(\%opt, @_);
}

around 'render' => sub {
	my $orig = shift;
	my $self = shift;

	if ($self->is_rendered) {
		return $self->buffer;
	}

	my @alignment;

	my $lines             = $self->lines;
	my $max_column_widths = $self->max_column_widths;

	if ($self->_is_width_constrained) {
		if ($self->max_width && ! $self->column_widths) {
			$self->_determine_column_widths();
		}
		($lines, $max_column_widths) = $self->_fit_lines_to_widths($lines);
	}

	my $last_line_index = $#{ $lines };
	foreach my $i (0..$last_line_index) {
		my ($opts, $columns) = @{ $lines->[$i] };
		my %start = (
			style => $opts->{style} || 'light',
		);
		if ($opts->{header} || $i == 0 || $opts->{top}) {
			$start{top} = $opts->{top} || $start{style};
		}
		if ($opts->{header} || $i == $last_line_index || $opts->{bottom}) {
			$start{bottom} = $opts->{bottom} || $start{style};
		}

		# Support special table-wide styles
		if ($self->style) {
			if ($self->style eq 'horizontal_double' && $i == $last_line_index) {
				$start{bottom} = 'double';
			}
		}

		if ($opts->{alignment}) {
			@alignment = @{ $opts->{alignment} };
		}

		my @parts = ( BOX_START(%start) );
		foreach my $j (0..$#{$columns}) {
			my $align = $opts->{header_alignment} ? $opts->{header_alignment}[$j]
					  : $opts->{header}           ? 'left'
					  : $alignment[$j] || undef;
			push @parts, $columns->[$j]->align_and_pad(width => $max_column_widths->[$j], align => $align);
			if ($j != $#{$columns}) {
				push @parts, BOX_RULE;
			}
			elsif ($j == $#{$columns}) {
				push @parts, BOX_END;
			}
		}
		$self->add_line(@parts);
	}

	$self->is_rendered(1);
	$self->$orig();
};

sub _push_line {
	my ($self, $opt, @columns) = @_;

	# Allow undef to be passed in columns; map it to ''
	$columns[$_] = '' foreach grep { ! defined $columns[$_] } 0..$#columns;

	# If split_lines, break up each cell into as many lines as necessary and recall _push_line for each new row
	my $do_split_lines = defined $opt->{split_lines} ? $opt->{split_lines} : $self->split_lines;
	if ($do_split_lines && grep { /\n/ } @columns) {
		my @new_rows;
		foreach my $i (0..$#columns) {
			my @split = split /\n/, $columns[$i];
			foreach my $j (0..$#split) {
				$new_rows[$j][$i] = $split[$j];
			}
		}
		$self->_push_line($opt, @$_) foreach @new_rows;
		return;
	}

	# Convert each column into a ::Text object so that I can figure out the length as
	# well as record max column widths
	my @strings;
	foreach my $i (0..$#columns) {
		my $string = BOX_STRING($columns[$i]);
		push @strings, $string;

		# Update record of max column widths
		$self->max_column_widths->[$i] = $string->length
			if ! $self->max_column_widths->[$i] || $self->max_column_widths->[$i] < $string->length;

		# Prepare for fitting logic
		if ($self->_is_width_constrained) {
			$string->_split_up_on_whitespace;
		}
	}

	push @{ $self->lines }, [ $opt, \@strings ];
}

sub _is_width_constrained {
	my $self = shift;
	return $self->max_width || $self->column_widths;
}

=doc _determine_column_widths

Pass no args, return nothing.  Figure out what the column widths should be where the caller has specified a custom max_width value that they'd like the whole table to be constrained to.

=cut

sub _determine_column_widths {
	my $self = shift;
	return if $self->column_widths;
	return if ! $self->max_width;

	# Max width represents the max width of the rendered table, with padding and box characters
	# Let's figure out how many characters will be used for rendering and padding
	my $column_count = int @{ $self->max_column_widths };
	my $padding_width = 1;
	my $rendering_characters_width =
		($column_count * ($padding_width * 2)) # space on left and right of each cell text
		+ $column_count + 1;                   # bars on right of each column + one on left in beginning

	# Prepare a checker for determining success
	my $widths_over = sub {
		my @column_widths = @_;
		return (sum (@column_widths) + $rendering_characters_width) - $self->max_width;
	};
	my $widths_fit = sub {
		my @column_widths = @_;
		if ($widths_over->(@column_widths) <= 0) {
			$self->column_widths( \@column_widths );
			return 1;
		}
		return 0;
	};

	# Escape early if the max column widths already fit the constraint
	return if $widths_fit->(@{ $self->max_column_widths });

	# Figure out longest word lengths
	my @longest_word_lengths;
	foreach my $line (@{ $self->lines }) {
		foreach my $column_index (0..$#{ $line->[1] }) {
			my $length = $line->[1][$column_index]->_longest_word_length;
			$longest_word_lengths[$column_index] = max($length, $longest_word_lengths[$column_index] || 0);
		}
	}

	if (sum (@longest_word_lengths) >= $self->max_width) {
		die "Don't yet know how to split words on non-whitespace boundries";
	}

	# Reduce the amout of wrapping as much as possible.  Try and fit in the max_width with breaking the
	# fewest possible columns.

	my @column_widths = @{ $self->max_column_widths };
	my @column_index_by_width = sort { $column_widths[$b] <=> $column_widths[$a] } 0..$#column_widths;

	while (! $widths_fit->(@column_widths)) {
		# Select the next widest column and try shortening it
		my $column_index = shift @column_index_by_width;
		if (! defined $column_index) {
			die "Shortened all the columns and found no way to fit";
		}

		my $overage = $widths_over->(@column_widths);
		my $new_width = $column_widths[$column_index] - $overage;
		if ($new_width < $longest_word_lengths[$column_index]) {
			$new_width = $longest_word_lengths[$column_index];
		}
		$column_widths[$column_index] = $new_width;
	}

	return;
}

=doc _fit_lines_to_widths (\@lines)

Pass an array ref of lines (most likely from $self->lines).  Return an array ref of lines wrapped to the $self->column_widths values, and an array ref of the new max column widths.

=cut

sub _fit_lines_to_widths {
	my ($self, $lines, @column_widths) = @_;

	@column_widths = @{ $self->column_widths } if ! @column_widths;
	if (! @column_widths) {
		die "Can't call _fit_lines_to_widths() without column_widths set or passed";
	}
	my @max_column_widths;

	my @new_lines;
	foreach my $line (@$lines) {
		my ($opts, $strings) = @$line;
		my @new_line;
		foreach my $column_index (0..$#column_widths) {
			my $string = $strings->[$column_index];
			my $width  = $column_widths[$column_index];

			# If no width constraint or if this string already fits, store and move on
			if (! $width || $string->length <= $width) {
				$new_line[0][$column_index] = $string;
				next;
			}

			# If we can, break the string on word boundries and fit that way
			if ($string->_longest_word_length <= $width) {
				my $row_index = 0;
				my $length = 0;
				my $buffer = '';
				my $store_buffer = sub {
					return unless $length;
					$new_line[$row_index++][$column_index] = BOX_STRING($buffer);
					$length = 0;
					$buffer = '';
				};

				# Place each word one at a time, breaking to a new row index each time we fill up a row
				foreach my $word (@{ $string->_words }) {
					if ($length + $word->length > $width) {
						$store_buffer->();
					}
					# Replace the space we split on in _split_up_on_whitespace
					if ($word->length && $length) {
						$buffer .= ' ';
						$length += 1;
					}
					$buffer .= $word->value;
					$length += $word->length;
				}
				$store_buffer->();
				next;
			}

			# We couldn't split on whitespace; the longest word exceeds the width.  We need to split
			# with hyphenation or just outright split at the width.

			die "Don't know yet how to proceed with splitting inside words";
		}
		foreach my $row_index (0..$#new_line) {
			# Every cell needs to have a string object
			foreach my $column_index (0..$#column_widths) {
				$new_line[$row_index][$column_index] ||= BOX_STRING('');

				# Update max_column_widths
				my $width = $new_line[$row_index][$column_index]->length;
				$max_column_widths[$column_index] = $width
					if ! $max_column_widths[$column_index] || $max_column_widths[$column_index] < $width;
			}
			push @new_lines, [ $opts, $new_line[$row_index] ];
		}
	}

	return (\@new_lines, \@max_column_widths);
}

=head2 output_width

Returns the width of the table if it were rendered right now without additional rows added.

=cut

sub output_width {
	my $self = shift;

	my $width = 1; # first pipe char
	
	foreach my $column_width (@{ $self->max_column_widths }) {
		$width += $column_width + 3; # 2: padding, 1: trailing pipe char
	}

	if ($self->max_width && $width > $self->max_width) {
		return $self->max_width; # FIXME: is this relastic?  What about for very small values of max_width and large count of columns?
	}

	return $width;
}

=head1 COPYRIGHT

Copyright (c) 2012 Eric Waters and Shutterstock Images (http://shutterstock.com).  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this module.

=head1 AUTHOR

Eric Waters <ewaters@gmail.com>

=cut

1;
