package Text::UnicodeBox::ASCIITable;

use Moose;
use Data::Dumper;
use Text::UnicodeBox;
extends 'Text::ASCIITable';

override 'new' => sub {
	my $class = shift;
	my $hash_ref = super;
	return bless $hash_ref, $class;
};

override 'draw' => sub {
	my ($self, $page) = @_;

	$page ||= 0;

	my $box = Text::UnicodeBox->new();

	delete $self->{cache_TableWidth}; # Clear cache
	$self->calculateColWidths;

	## Don't yet support 'hide_FirstLine' option
	# $contents .= $self->getPart($page,$self->drawLine($tstart,$tstop,$tline,$tdelim)) unless $self->{options}{hide_FirstLine};

=cut
	if (defined($self->{options}{headingText})) {
		my $title = $self->{options}{headingText};
		if ($title =~ m/\n/) { # Multiline title-support
			my @lines = split(/\r?\n/,$title);
			foreach my $line (@lines) {
				$contents .= $self->getPart($page,$self->drawSingleColumnRow($line,$self->{options}{headingStartChar} || '|',$self->{options}{headingStopChar} || '|',$self->{options}{headingAlign} || 'center','title'));
			}
		} else {
			$contents .= $self->getPart($page,$self->drawSingleColumnRow($self->{options}{headingText},$self->{options}{headingStartChar} || '|',$self->{options}{headingStopChar} || '|',$self->{options}{headingAlign} || 'center','title'));
		}
		$contents .= $self->getPart($page,$self->drawLine($mstart,$mstop,$mline,$mdelim)) unless $self->{options}{hide_HeadLine};
	}

	unless ($self->{options}{hide_HeadRow}) {
		# multiline-column-support
		foreach my $row (@{$self->{tbl_multilinecols}}) {
			$contents .= $self->getPart($page,$self->drawRow($row,1,$trstart,$trstop,$trdelim));
		}
	}
	$contents .= $self->getPart($page,$self->drawLine($mstart,$mstop,$mline,$mdelim)) unless $self->{options}{hide_HeadLine};
=cut
	my $i=0;
	for (@{$self->{tbl_rows}}) {
		$i++;
		print Dumper($_);
		#$contents .= $self->getPart($page,$self->drawRow($_,0,$mrstart,$mrstop,$mrdelim));
		if (($self->{options}{drawRowLine} && $self->{tbl_rowline}{$i} && ($i != scalar(@{$self->{tbl_rows}}))) || 
			(defined($self->{tbl_lines}{$i}) && $self->{tbl_lines}{$i} && ($i != scalar(@{$self->{tbl_rows}})) && ($i != scalar(@{$self->{tbl_rows}})))) {
			#$contents .= $self->getPart($page,$self->drawLine($rstart,$rstop,$rline,$rdelim)) 
		}
	}
	#$contents .= $self->getPart($page,$self->drawLine($bstart,$bstop,$bline,$bdelim)) unless $self->{options}{hide_LastLine};

	#return $contents;

	return '';
};

sub original_draw {
  my $self = shift;
  my ($top,$toprow,$middle,$middlerow,$bottom,$rowline,$page) = @_;
  my ($tstart,$tstop,$tline,$tdelim) = defined($top) ? @{$top} : @{$self->{des_top}};
  my ($trstart,$trstop,$trdelim) = defined($toprow) ? @{$toprow} : @{$self->{des_toprow}};
  my ($mstart,$mstop,$mline,$mdelim) = defined($middle) ? @{$middle} : @{$self->{des_middle}};
  my ($mrstart,$mrstop,$mrdelim) = defined($middlerow) ? @{$middlerow} : @{$self->{des_middlerow}};
  my ($bstart,$bstop,$bline,$bdelim) = defined($bottom) ? @{$bottom} : @{$self->{des_bottom}};
  my ($rstart,$rstop,$rline,$rdelim) = defined($rowline) ? @{$rowline} : @{$self->{des_rowline}};
  my $contents=""; $page = defined($page) ? $page : 0;

  delete $self->{cache_TableWidth}; # Clear cache
  $self->calculateColWidths;

  $contents .= $self->getPart($page,$self->drawLine($tstart,$tstop,$tline,$tdelim)) unless $self->{options}{hide_FirstLine};
  if (defined($self->{options}{headingText})) {
    my $title = $self->{options}{headingText};
    if ($title =~ m/\n/) { # Multiline title-support
      my @lines = split(/\r?\n/,$title);
      foreach my $line (@lines) {
        $contents .= $self->getPart($page,$self->drawSingleColumnRow($line,$self->{options}{headingStartChar} || '|',$self->{options}{headingStopChar} || '|',$self->{options}{headingAlign} || 'center','title'));
      }
    } else {
      $contents .= $self->getPart($page,$self->drawSingleColumnRow($self->{options}{headingText},$self->{options}{headingStartChar} || '|',$self->{options}{headingStopChar} || '|',$self->{options}{headingAlign} || 'center','title'));
    }
    $contents .= $self->getPart($page,$self->drawLine($mstart,$mstop,$mline,$mdelim)) unless $self->{options}{hide_HeadLine};
  }

  unless ($self->{options}{hide_HeadRow}) {
		# multiline-column-support
		foreach my $row (@{$self->{tbl_multilinecols}}) {
			$contents .= $self->getPart($page,$self->drawRow($row,1,$trstart,$trstop,$trdelim));
		}
	}
  $contents .= $self->getPart($page,$self->drawLine($mstart,$mstop,$mline,$mdelim)) unless $self->{options}{hide_HeadLine};
  my $i=0;
  for (@{$self->{tbl_rows}}) {
    $i++;
    $contents .= $self->getPart($page,$self->drawRow($_,0,$mrstart,$mrstop,$mrdelim));
		if (($self->{options}{drawRowLine} && $self->{tbl_rowline}{$i} && ($i != scalar(@{$self->{tbl_rows}}))) || 
				(defined($self->{tbl_lines}{$i}) && $self->{tbl_lines}{$i} && ($i != scalar(@{$self->{tbl_rows}})) && ($i != scalar(@{$self->{tbl_rows}})))) {
	    $contents .= $self->getPart($page,$self->drawLine($rstart,$rstop,$rline,$rdelim)) 
		}
  }
  $contents .= $self->getPart($page,$self->drawLine($bstart,$bstop,$bline,$bdelim)) unless $self->{options}{hide_LastLine};

  return $contents;
}

1;
