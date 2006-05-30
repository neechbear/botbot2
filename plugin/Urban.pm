package plugin::Urban;
use base plugin;
use strict;
use WWW::Search qw();

sub handle {
	my ($self,$event,$responded) = @_;
	my $talker = $self->{talker};

	return if $event->{'msgtype'} eq 'ALRM';
	return 0 unless $event->{command} =~ /^urban$/i;

	my $key = 'e1022d9e0af608374a5c88f5e0f379c5';
	my $search = WWW::Search->new('UrbanDictionary', key => $key);
	$search->timeout(5);
	$search->native_query(join(' ',@{$event->{cmdargs}}));

	my @results = $search->results();
	unless (exists $results[0]->{description} && length($results[0]->{description})) {
		$talker->whisper(
				$event->{person},
				'Sorry. I failed miserably to look that up for you'
			);
		return 0;

	} else {
		my $reply = sprintf("'%s': %s %s",
				$results[0]->{word},
				$results[0]->{description},
				($results[0]->{example} ? "(Example: $results[0]->{example})" : '')
			);

		$reply = sprintf("Result 1 of %d for %s", ($#results + 1), $reply)
					if ($#results + 1) > 1;

		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$reply
			);

		return "gave an urban dictionary definition";
	}

}

1;

