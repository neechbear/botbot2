package plugin::Google;
use base plugin;
use strict;
use WWW::Search;
use HTML::Strip;

our $DESCRIPTION = 'Return the first google result for a search term';
our %CMDHELP = (
		'google <query>   ' => 'Search google using the search term <query>',
		'googlefor <query>' => 'Alias of google',
		'search <query>   ' => 'Alias of google',
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^(googlefor|google|search)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});

	my $key = 'xs9uhr9QFHJsxYJV6zO5TBob4K7kuygs';
	my $search = WWW::Search->new('Google', key => $key, safe => 0);
	my $sQuery = WWW::Search::escape_query($str);
	$search->native_query($sQuery);
	my $result = $search->next_result();

	if (defined $result) {
		my $hs = HTML::Strip->new();
		my $reply = $hs->parse(' '.$result->url.' - '.
							$result->title.' - '.
							$result->description);

		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$reply
			);
		return "Returned the first google search result for $str";

	} else {
		$talker->whisper(
				$event->{person},
				'Sorry. I failed miserably to look that up for you'
			);
		return 0;
	}
}

1;

