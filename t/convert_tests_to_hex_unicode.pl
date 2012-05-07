#!/usr/bin/env perl

=head1

I've discovered that I can't write these tests in UTF-8 character set and expect that the tests will pass in all CPAN tester environments.  It appears that OpenBSD, FreeBSD, and other environments that may not default to LC_ALL=*.UTF-8 character set will not run these tests correctly.  Consequently, I'm going to maintain two copies of tests.  One, in this directory, which has been converted by this script into a format which those without UTF-8 locales should be able to run.  The other, the src/ directory, contains the more me-friendly tests.  This script converts between src/ and this directory.

=cut

use strict;
use warnings;
use FindBin;
use utf8;

foreach my $file (glob "$FindBin::Bin/src/*.t") {
	print "Working on $file...\n";
	my ($file_name) = $file =~ m{/([^/]+)$};
	my $dest_file = $FindBin::Bin . '/' . $file_name;

	open my $out, '>', $dest_file or die "Can't write to $dest_file: $!";
	open my $in, '<', $file or die "Can't read $file: $!";

	binmode $in, ':utf8';

	while (my $line = <$in>) {
		foreach my $char (split //, $line) {
			my $ord = ord($char);
			if ($ord > 255) {
				printf $out '\x{%x}', $ord;
			}
			elsif ($ord > 127) {
				# Recommended by perluniintro
				printf $out '".pack("U", 0x%x)."', $ord;
			}
			else {
				print $out $char;
			}
		}
	}

	close $in;
	close $out;
}
