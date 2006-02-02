
sub _dict {
	my $talker = shift;
	my $event = { @_ };

	return 0 unless length($event->{args}->[0]);
	pop @{$event->{args}} if $event->{list};
	my $str = join(' ',@{$event->{args}});

	my @reply;
	my $dict = Net::Dict->new('dict.org');
	my $h = $dict->define($str);
	foreach my $i (@{$h}) {
		my ($db, $def) = @{$i};
		my @lines = split(/\n/,$def);
		my $c = 0;
		my $maxlines = 7;
		my $skipped = 1;
		for (@lines) {
			if ($c >= $maxlines && $event->{msgtype} ne 'TELL') {
				push @reply, " ... (truncated; displayed $maxlines lines of ".@lines.") ...";
				last;
			}
			push @reply,$_;
			$c++;
		}
		last;
	}

	unless (@reply) {
		$talker->whisper(
				$event->{person},
				'Sorry, I couldn\'t find a dictionary definition for you'
			);
	} else {
		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @reply;
	}

	return 0;
}

