#!/home/nicolaw/perl-5.8.8/bin/perl -w

use strict;
use SOAP::Lite;
use HTML::Strip;
use HTML::Entities;

my $query = @ARGV ? "@ARGV" : die "Usage: perl googly.pl <query>\n";

my $command = 'google';
my $restricts = $command =~ /^(linux|bsd|mac)$/ ? lc($command) : '';

my $google_key = 'fHv/eCZQFHJNeSmGVPec7zJqmifn0Lsm';
my $google_wdsl = "./GoogleSearch.wsdl";
my $google_search = SOAP::Lite->service("file:$google_wdsl");

# http://www.google.com/apis/reference.html#searchrequest
my $results = $google_search->doGoogleSearch(
		$google_key,	# key
		$query,		# query
		0,		# start
		10,		# maxResults
		"true",		# filter
		$restricts,	# restricts
		"false",	# safeSearch
		"lang_en",	# lr
		"latin1",	# ie
		"latin1"	# oe
	);

my $suggestion = $google_search->doSpellingSuggestion(
		$google_key,	# key
		$query		# phrase
	);

if (defined $suggestion) {
	print "Did you mean '$suggestion'?\n\n";
}

if (defined $results->{resultElements} && @{$results->{resultElements}}) {
	foreach my $result (@{$results->{resultElements}}) {
		print join("\n",  
			html2text(($result->{title} || "no title")),
			$result->{URL},
			html2text(($result->{snippet} || 'no snippet')),
			"\n");
	}
}

sub html2text {
	my @out = @_;
	my $hs = HTML::Strip->new();
	for (@out) {
		$_ = $hs->parse($_);
		$_ = HTML::Entities::decode($_);
		s/\n/ /gs; s/\s\s+/ /g;
	}
	return @out;
}

