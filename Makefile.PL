use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'Text::UnicodeBox',
	AUTHOR              => q{Eric Waters <ewaters@shutterstock.com>},
	VERSION_FROM        => 'lib/Text/UnicodeBox.pm',
	ABSTRACT            => 'Formatting using unicode box symbols',
	($ExtUtils::MakeMaker::VERSION >= 6.3002
		? ('LICENSE'=> 'perl')
		: ()),
	PL_FILES            => {},
	PREREQ_PM => {
		'Moose'            => 0,
		'Term::ANSIColor'  => 0,
		'Test::More'       => 0,
	},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'media-*' },
);
