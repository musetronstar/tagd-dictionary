#!/usr/bin/perl

use strict;
use warnings;

# input must be sorted by words (first column) or word::sense_count will contain duplicates
my $sense_count = 0;
my $container;
my $letter = '';
my $last_word = '';

my %POS_abv = (
	# Parts of Speech as listed in VOA word book
	'n.' => 'noun',              # a name word
	'v.' => 'verb',              # an action word
	'ad.' => 'adjective_adverb', # adjective/adverb - a describing word
	'adj.' => 'adjective',       # not listed in the word book but occurs
	'prep.' => 'preposition',    # a word used to show a relation
	'pro.' => 'pronoun',         # a word used in place of a noun
	'conj.' => 'conjunction',    # a joining word
);

my $usage = "usage: $0 <namespace> <word-list-defs-tsv-file>";
@ARGV == 2 or die $usage;
my $namespace = shift @ARGV or die $usage;

while (<>) {
	next if /^\s*#/;  # ignore comment

	chomp;

	# tsv data in the form
	# 0          1         2                  3
	# word <tab> pos <tab> definition [ <tab> comment(s) ]
	my ($word, $pos, $def, $ex) = split /\t/;

	my $ltr = uc(substr($word, 0, 1));
	if ( $ltr =~ /[A-Z]/ and $ltr ne $letter ) {
		$letter = $ltr;
		print "-*** letter $letter ***-\n\n";
		$container = "$namespace:$letter";
		print ">> $container contained_in $namespace represents letter = \"$letter\"\n\n";
	}

	if ( $word eq $last_word ) {
		$sense_count++;
	} else {
		$sense_count = 0;
	}

	print ">> \"$namespace:$word:$sense_count\" defined_in $container\n";
	print "represents word = \"$word\"\n";

	if ( exists $POS_abv{$pos} ) {
		print "categorized_as $POS_abv{$pos}\n";
	} else {
		die "unknown part of speech: $pos";
	}

	$def =~ s/\"/\\\"/g;
	print "_has definition = \"$def\"\n" if $def;

	if ( $ex ) {
		$ex =~ s/\"/\\\"/g;
		print "_has example = \"$ex\"\n";
	}

	print "\n";

	$last_word = $word;
}
