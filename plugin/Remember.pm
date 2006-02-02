
sub _remember {
	my $talker = shift;
	my $event = { @_ };

	return 0 unless length($event->{args}->[0]);
	pop @{$event->{args}} if $event->{list};
	my $str = join(' ',@{$event->{args}});
	$str =~ s/\s+/\.\*/g;

	my @reply;
	if (open(URL,"<$ROOT/logs/url.log")) {
		while (local $_ = <URL>) {
			chomp;
			if (/$str/i) {
				my ($time,$person,$url,$tinyurl,$list,$title) = split(/\t/,$_);
				unless ($title) {
					my ($title2,$response) = getHtmlTitle($url);
					$title = $title2;
				}
				unless ($tinyurl) {
					$tinyurl = tinyURL($url) || $url;
				}
				push @reply, "$person once mentioned $tinyurl - $title";
			}
		}
		close(URL);
	}

	@reply = ("Sorry. I don't remember $str.") unless @reply;

	$talker->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$reply[int(rand(@reply))]
		);

	return 0;
}

