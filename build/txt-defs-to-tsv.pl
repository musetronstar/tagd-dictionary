#!/usr/bin/perl

use strict;
use warnings;

# Parses VOA Word Book using output from pdftotext

my %POSs = (
	'n.'	=> 1,
	'v.'	=> 1,
	'ad.'	=> 1,
	'prep.'	=> 1,
	'pro.'	=> 1,
	'conj.'	=> 1,
# adj not listed in the word book part of speech section
# but used nonetheless
	'adj.'	=> 1
);

sub print_defs {
	my $word = shift;
	my $defs = shift;

	my $pos;
	my @phrases = split /;\s*/, $defs;
	foreach my $phrase (@phrases) {
		$phrase =~ s/^\s+|\s+$//g; # trim

		# same word, another part of speech/def (captures pos split on)
		my @defs = split /((?:n|v|ad|prep|pro|conj|adj)\.) /, $phrase;
		foreach my $def (@defs) {
			$def =~ s/^\s+|\s+$//g; # trim
			next if not $def;

			if ($POSs{$def}) {
				$pos = $def;
				next;
			}

			die "no pos" if !$pos;

			my $exidx = rindex($def, '("');  # close paren of and example ("for example")
			if ($exidx > 0) { # strip example if any, print in 4th column
				my $ex = substr $def, $exidx;
				$ex =~ s/[()"]//g;
				$def = substr $def, 0, $exidx-1;
				print "$word\t$pos\t$def\t$ex\n";
			} else {
				print "$word\t$pos\t$def\n";
			}

		}
	}
}

# current word/definitions
my $word = undef;
my $defs = undef;

while (<>) {
	# grab word, part of speech, and definition (which may wrap multiple lines)
	# ex:
	# tax – n. the money a person or business must pay
	# to the government so the government can
	# provide services
	if (/(.+) - ?(\w+\. .*)$/) {
		print_defs($word, $defs) if $defs;
		$word = $1;
		$defs = $2;
	} elsif (/^$/) {
		print_defs($word, $defs) if $defs;
		$defs = undef;
	} elsif ($defs) {  # continuation of definition on previous line
		chomp;
		$defs .= " $_";
	}
}

print_defs($word, $defs) if $defs;
