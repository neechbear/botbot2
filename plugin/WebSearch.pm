package plugin::WebSearch;
use base plugin;
use strict;
use WWW::Search;
use HTML::Strip;

my $DESCRIPTION = 'Return the first Yahoo!, AltaVista, Lycos or HotBot search result';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;

	my %plugin = (
			yahoo       => 'Yahoo',
			hotbot      => 'HotBot',
			lycos       => 'Lycos',
			altavista   => 'AltaVista',
			ebay        => 'EbayUK',
			crawler     => 'Crawler',
			netfind     => 'NetFind',
			metapedia   => 'Metapedia',
			metacrawler => 'MetaCrawler',
			hotfiles    => 'HotFiles',
			fireball    => 'Fireball',
			excite      => 'ExciteForWebServers',
		);

	my $commands = join('|',keys %plugin);
	return unless $event->{command} =~ /^($commands)$/i;

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});

	my $search = WWW::Search->new($plugin{lc($event->{command})});
	my $sQuery = WWW::Search::escape_query($str);
	$search->native_query($sQuery);
	my $result = $search->next_result();

	if (defined $result) {
		my $hs = HTML::Strip->new();
		my $reply = $hs->parse(' '.$result->url.' - '.
							$result->title.' - '.
							$result->description);

		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$reply
			);
		return "Returned the first search engine result for $str";

	} else {
		$self->{talker}->whisper(
				$event->{person},
				'Sorry. I failed miserably to look that up for you'
			);
		return 0;
	}
}

1;

