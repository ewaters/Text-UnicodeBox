package Text::UnicodeBox::Utility;

use strict;
use warnings;
use charnames ();
use Exporter 'import';

our @EXPORT_OK = qw(find_box_unicode_name fetch_box_character);

sub fetch_box_character {
    my $name = find_box_unicode_name(@_);
	return undef unless $name;
    return charnames::string_vianame($name);
}

sub find_box_unicode_name {
    my %directions = @_;

    # Expand shorthand
    foreach my $direction (keys %directions) {
        $directions{$direction} = 'light' if $directions{$direction} . '' eq '1';
    }

    # Convert left & right to horizontal, up & down to vertical
    if ($directions{down} && $directions{up} && $directions{down} eq $directions{up}) {
        $directions{vertical} = delete $directions{down};
        delete $directions{up};
    }
    if ($directions{left} && $directions{right} && $directions{left} eq $directions{right}) {
        $directions{horizontal} = delete $directions{left};
        delete $directions{right};
    }

    # Group together styles
    my %styles;
    while (my ($direction, $style) = each %directions) {
        push @{ $styles{$style} }, $direction;
    }
    my @styles = keys %styles;

    my $base_name = 'box drawings ';
    my @variations;

    if (int @styles == 1) {
        # Only one style; should be at most only two directions
        my @directions = @{ $styles{ $styles[0] } };
        if (int @directions > 2) {
            die "Unexpected scenario; one style but more than 2 directions";
        }
        foreach my $variation (\@directions, [ reverse @directions ]) {
            push @variations, uc $base_name . $styles[0] . ' ' . join (' and ', @$variation);
        }
    }
    elsif (int @styles == 2) {
        my @parts;
        foreach my $style (@styles) {
            my @directions = @{ $styles{$style} };
            if (int @directions > 1) {
                # right/left down/up/vertical, never down/up/vertical left/right
                # up/down horizontal, never horizontal up/down
                if (
                    ($directions[0] =~ m/^(down|up|vertical)$/ && $directions[1] =~ m{^(left|right)$})
                    || ($directions[0] =~ m/^(horizontal)$/ && $directions[1] =~ m{^(up|down)$})
                ) {
                    @directions = reverse @directions;
                }
            }
            push @parts, join ' ', @directions, $style;
        }
        foreach my $variation (\@parts, [ reverse @parts ]) {
            push @variations, uc $base_name . join(' and ', @$variation);
        }
    }

    if (! @variations) {
        return undef;
    }

    foreach my $variation (@variations) {
        next unless charnames::vianame($variation);
        return $variation;
    }
    return undef;
}

1;
