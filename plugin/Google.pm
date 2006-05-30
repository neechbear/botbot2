package plugin::Google;
use base plugin;
use strict;
use SOAP::Lite;
use URLTools;

our $DESCRIPTION = 'Return the first google result for a search term';
our %CMDHELP = (
		'google <query>   ' => 'Search google using the search term <query>',
		'googlefor <query>' => 'Alias of google',
		'search <query>   ' => 'Alias of google',
		'linux <query>    ' => 'Search google for linux results using the search term <query>',
		'bsd <query>      ' => 'Search google for BSD results using the search term <query>',
		'mac <query>      ' => 'Search google for Mac results using the search term <query>',
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^(googlefor|google|search|linux|bsd|mac)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;

	return 0 unless length($event->{cmdargs}->[0]);
	my $query = join(' ',@{$event->{cmdargs}});

	my $restricts = $event->{command} =~
		/^(linux|bsd|mac)$/ ? lc($event->{command}) : '';

	my $google_key = 'fHv/eCZQFHJNeSmGVPec7zJqmifn0Lsm';
	my $google_wdsl = "$self->{root}/GoogleSearch.wsdl";
	my $google_search = SOAP::Lite->service("file:$google_wdsl");

	my $start = time;

	# http://www.google.com/apis/reference.html#searchrequest
	my $results = $google_search->doGoogleSearch(
			$google_key,	# key
			$query,			# query
			0,				# start
			10,				# maxResults
			"true",			# filter
			$restricts,		# restricts
			"false",		# safeSearch
			"lang_en",		# lr
			"latin1",		# ie
			"latin1"		# oe
		);

	my $suggestion = $google_search->doSpellingSuggestion(
			$google_key,	# key
			$query			# phrase
		);

	my $end = time;
	my $duration = $end - $start;

	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			"Did you mean '$suggestion'?"
		) if defined $suggestion;

	if (defined $results->{resultElements} && @{$results->{resultElements}}) {
		foreach my $result (@{$results->{resultElements}}) {
			my $tinyurl = $duration <= 4 ? tinyURL($result->{URL}) : '';
			my $reply = html2text(($result->{title} || "no title")).' - '.
					"$result->{URL} - ".
					($tinyurl ? "$tinyurl - " : '').
					html2text(($result->{snippet} || 'no snippet'));

			$self->{talker}->whisper(
					($event->{list} ? $event->{list} : $event->{person}),
					$reply
				);
			return "Returned the first google search result for $query";
		}

	} else {
		$self->{talker}->whisper(
				$event->{person},
				'Sorry. I failed miserably to look that up for you'
			);
		return 0;
	}
}

1;

