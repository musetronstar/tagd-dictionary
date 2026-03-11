#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# the n in ngrams
use constant N => 5;

use constant WORD_POS => 0;
use constant WORD_DEF => 1;
use constant WORD_EX => 2;
# (
# 	<word> => [
#		[ <pos>, <definition>, <example> ]
# 	]
# )
my %words;

# (
# 	<pos> => <count>
# )
my %POSs;

use constant TSV_WORD => 0;
use constant TSV_POS => 1;
use constant TSV_DEF => 2;
use constant TSV_EX => 3;

sub add_pos {
	my $pos = shift;
	if($POSs{$pos}) {
		$POSs{$pos}++;
	} else {
		$POSs{$pos} = 1;
	}
	return $pos;
}

sub parse_tsv {
	while (<>) {
		chomp;

		# tsv data in the form
		# 0          1         2                  3
		# word <tab> pos <tab> definition [ <tab> comment(s) ]
		my @cols = split /\t/;
		my $data;
		if (@cols == 3) {
			$data = [ add_pos($cols[TSV_POS]), $cols[TSV_DEF] ];
		} elsif (@cols == 4) {
			$data = [ add_pos($cols[TSV_POS]), $cols[TSV_DEF], $cols[TSV_EX] ];
		} else {
			die "malformed data: $_";
		}

		if (exists $words{$cols[TSV_WORD]}) {
			push @{$words{$cols[TSV_WORD]}}, $data;
		} else {
			$words{$cols[TSV_WORD]} = [ $data ];
		}
	}
}

sub parts_of_speech {
	my $word = shift;
	my $elems = $words{$word} or return undef;
	return join(',', map {$_->[WORD_POS]} @$elems);
}

sub has_part_of_speech {
	my $word = shift;
	my $pos = shift;
	my $count = 0;
	if ($words{$word}) {
		foreach (@{$words{$word}}) {
			$count++ if ($_->[WORD_POS] eq $pos);
		}
	}
	return $count;
}

sub print_ngrams {
	$_ = lc(shift);

	my @phrases = split /[,.;|()"]/;
	foreach my $phrase (@phrases) {
		$phrase =~ s/^\s+|\s+$//g; # trim
		next if not $phrase;
		my @words = split /\s+/, $phrase;
		while (@words > 0) {
			for (my $i=0; $i<N && $i<@words; $i++) {
				my @ngrams;
				for (my $j=0; $j<=$i && $j<@words; $j++) {
					push @ngrams, $words[$j];
				}
				my $ngrams = join(' ', @ngrams);
				my $pos_str = parts_of_speech($ngrams);
				print $ngrams.($pos_str ? "\t$pos_str" : "")."\n";
			}
			shift @words;
		}
	}
}

sub cmd_ngrams {
	foreach my $word (keys %words) {
		print_ngrams($word);
		foreach my $elem (@{$words{$word}}) {
			print_ngrams($elem->[WORD_DEF]);
			print_ngrams($elem->[WORD_EX]) if $elem->[WORD_EX];
		}
	}
}

sub match_span_pos {
	my $word = shift;
	my $has_pos = shift;  # has_pos function ref
	my $handler = shift;  # span_pos handler function ref
	$_ = lc(shift);		  # text segment

	my @phrases = split /[,.;()"|]/;
	foreach my $phrase (@phrases) {
		$phrase =~ s/^\s+|\s+$//g; # trim
		next if not $phrase;
		my @words = split /\s+/, $phrase;
		# print "##'@words'\n";
		my @span;  # span of words leading up to pos match
		my $ngram_match;  # longest ngrams sequence that matches a pos
		while (@words > 0) {
			for (my $i=0; $i<N && $i<@words; $i++) {
				my @ngrams;
				for (my $j=0; $j<=$i && $j<@words; $j++) {
					push @ngrams, $words[$j];
				}
				my $ngrams = join(' ', @ngrams);
				if ($has_pos->($ngrams)) {
					$ngram_match = $ngrams;
				}
			}
			last if $ngram_match;
			push(@span, shift @words);
		}
		$handler->($word, join(' ', @span), $ngram_match) if ($ngram_match && @span > 0);
	}
}


# print the spans of text leading up to a word of the given pos
sub cmd_span_pos {
	my $pos = shift;

	my $has_pos = sub {
		my $word = shift;

		my $elems = $words{$word} or return 0;
		my $count = 0;
		map { $count++ if ($_->[WORD_POS] eq $pos); } @$elems;

		return $count;
	};

	my $print_span_pos = sub {
		my $word = shift;
		my $span = shift;
		my $ngram_match = shift;

		print "$span\t$pos\n";
	};

	foreach my $word (keys %words) {
		foreach my $elem (@{$words{$word}}) {
			match_span_pos($word, $has_pos, $print_span_pos, $elem->[WORD_DEF]);
			match_span_pos($word, $has_pos, $print_span_pos, $elem->[WORD_EX]) if $elem->[WORD_EX];
		}
	}
}

sub cmd_taglize {
	my $pos_span_replacements_file = shift;

	my $fh;
	open $fh, $pos_span_replacements_file
		or die "failed to open `$pos_span_replacements_file': $!";

	my $SPAN_POS = 0;
	my $SPAN_REPL = 1;
	# pos span replacements
	# (
	# 	<span> => [
	# 		[ <pos>, <tagl-replacement> ]
	# 	]
	# )
	my %spans;

	# pos frequency in span replacements
	# (
	# 	<pos> => <freq>
	# )
	my %match_pos;

	while (<$fh>) {
		chomp;
		# ex:
    	# 297 a	n.	is_a
		if (/(?:\s*\d+\s+)?([^\t]+)\t([^\t]+)\t(.+)/) {
			if ($spans{$1}) {
				push @{$spans{$1}}, [$2, $3];
			} else {
				$spans{$1} = [ [$2, $3] ];
			}
			$match_pos{$2}++;
		}
	}

	close $fh;

	#print Dumper(\%spans)."\n";

	my $taglize_span_pos = sub {
		my $word = shift;
		my $span = shift;
		my $match = shift;

		#print "----------------------\n";
		# TAGL statements are in the form:
		#	subject relator object
		# which will become:
		#	<tagl-word> <tagl-span-replacement> <tagl-match>
		#print "word: $word\n";
		my $word_elems = $words{$word} or return;
		#print Dumper($word_elems)."\n";

		#print "span: $span\n";
		my $span_elems = $spans{$span} or return;
		#print Dumper($span_elems)."\n";

		#print "match: $match\n";
		my $match_elems = $words{$match} or return;
		#print Dumper($match_elems)."\n";

		# taglize, replace spaces with underscores
		$word =~ s/ /_/g;
		$match =~ s/ /_/g;

		my %uniq_pos;
		my $count = 0;
		foreach my $match_elem (@$match_elems) {
			next if (++$uniq_pos{$match_elem->[WORD_POS]} > 1);
			foreach my $span_elem (@$span_elems) {
				if ($match_elem->[WORD_POS] eq $span_elem->[$SPAN_POS]) {
					print "tagl: $word $span_elem->[$SPAN_REPL] $match;\n";
					$count++;
				}
			}
		}

		if ($count) {
			foreach my $elem (@$word_elems) {
				print "$word\t$elem->[WORD_POS]\t$elem->[WORD_DEF]"
					.($elem->[WORD_EX] ? "\t$elem->[WORD_EX]\n" : "\n");
			}
		}
	};

	foreach my $pos (keys %match_pos) {
		my $has_pos = sub {
			my $word = shift;

			my $elems = $words{$word} or return 0;
			my $count = 0;
			map { $count++ if ($_->[WORD_POS] eq $pos); } @$elems;

			return $count;
		};

		foreach my $word (keys %words) {
			foreach my $elem (@{$words{$word}}) {
				match_span_pos($word, $has_pos, $taglize_span_pos, $elem->[WORD_DEF]);
			}
		}
	}
}

my $cmd = 'ngrams';
if (@ARGV > 1 ) {
	$cmd = shift @ARGV;
}

if ($cmd eq 'ngrams') {
	parse_tsv();
	cmd_ngrams();
} elsif ($cmd eq 'span-pos') {
	my $pos = shift @ARGV;
	parse_tsv();
	die "no such part of speech: $pos" if !$POSs{$pos};
	cmd_span_pos($pos);
} elsif ($cmd eq 'taglize') {
	my $pos_span_replacements_file = shift @ARGV;
	parse_tsv();
	cmd_taglize($pos_span_replacements_file );
} else {
	die "usage: $0 ngrams | span-pos <pos> | taglize <pos-span-replacements> <tsv-wordlist>";
}


