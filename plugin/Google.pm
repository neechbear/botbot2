
sub _googlefor {
	my $talker = shift;
	my $event = { @_ };

	return 0 unless length($event->{args}->[0]);
	pop @{$event->{args}} if $event->{list};

	my $key = 'xs9uhr9QFHJsxYJV6zO5TBob4K7kuygs';
	my $search = WWW::Search->new('Google', key => $key, safe => 0);
	$search->native_query(join(' ',@{$event->{args}}));
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
	} else {
		$talker->whisper(
				$event->{person},
				'Sorry. I failed miserably to look that up for you'
			);
	}

	return 0;
}

