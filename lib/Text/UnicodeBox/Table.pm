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
extends 'Text::UnicodeBox';

has 'lines'             => ( is => 'rw', default => sub { [] } );
has 'max_column_widths' => ( is => 'rw', default => sub { [] } );
has 'style'             => ( is => 'rw', default => 'light' );
has 'is_rendered'       => ( is => 'rw' );

=head1 METHODS

=head2 new

=over 4

=item style

  my $table = Text::UnicodeBox::Table->new( style => 'horizontal_double ');

You may specify a certain style for the table to be drawn.  This may be overridden on a per row basis.

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

	my @lines = @{ $self->lines };
	foreach my $i (0..$#lines) {
		my ($opts, $columns) = @{ $lines[$i] };
		my %start = (
			style => $opts->{style} || 'light',
		);
		if ($opts->{header} || $i == 0 || $opts->{top}) {
			$start{top} = $opts->{top} || $start{style};
		}
		if ($opts->{header} || $i == $#lines || $opts->{bottom}) {
			$start{bottom} = $opts->{bottom} || $start{style};
		}

		# Support special table-wide styles
		if ($self->style) {
			if ($self->style eq 'horizontal_double' && $i == $#lines) {
				$start{bottom} = 'double';
			}
		}

		if ($opts->{alignment}) {
			@alignment = @{ $opts->{alignment} };
		}

		my @parts = ( BOX_START(%start) );
		foreach my $j (0..$#{$columns}) {
			my $align = $opts->{header_alignment} ? $opts->{header_alignment}[$j] : $opts->{header} ? 'left' : $alignment[$j] || undef;
			push @parts, $columns->[$j]->align_and_pad(width => $self->max_column_widths->[$j], align => $align);
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

	# Convert each column into a ::Text object so that I can figure out the length as
	# well as record max column widths
	my @strings;
	foreach my $i (0..$#columns) {
		my $string = BOX_STRING($columns[$i]);
		push @strings, $string;
		$self->max_column_widths->[$i] = $string->length
			if ! $self->max_column_widths->[$i] || $self->max_column_widths->[$i] < $string->length;
	}

	push @{ $self->lines }, [ $opt, \@strings ];
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
	return $width;
}

=head1 COPYRIGHT

Copyright (c) 2012 Eric Waters and Shutterstock Images (http://shutterstock.com).  All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with this module.

=head1 AUTHOR

Eric Waters <ewaters@gmail.com>

=cut

1;
