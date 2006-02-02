
sub _traceroute {
	my $talker = shift;
	my $event = { @_ };

	return 0 unless length($event->{args}->[0]);
	pop @{$event->{args}} if $event->{list};
	my $ip = isIP($event->{args}->[0]) ? $event->{args}->[0] :
				(host2ip($event->{args}->[0]))[0];

	unless (isIP($ip)) {
		$talker->whisper(
				$event->{person},
				"Sorry; $event->{args}->[0] isn't a valid host/IP"
			);
		return 0;
	}

	if (open(TR,"/usr/sbin/traceroute -w 3 -m 20 $ip|")) {
		my $failCnt = 0;
		while (local $_ = <TR>) {
			chomp;
			$failCnt++ if /\* \* \*/;
			last if $failCnt >= 3;
			$talker->whisper(
					($event->{list} ? $event->{list} : $event->{person}),
					$_
				);
		}
		close(TR);
	}

	return 0;
}

