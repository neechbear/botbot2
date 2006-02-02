
sub _iana {
	my $talker = shift;
	my $event = { @_ };

	return 0 unless length($event->{args}->[0]) && isIP($event->{args}->[0]);
	my $ip = $event->{args}->[0];

	eval {
		my $iana = new Net::Whois::IANA;
		$iana->whois_query(-ip=>$ip);

		my @reply = ("IANA Details for $ip:");
		push @reply, "  Country: " . $iana->country();
		push @reply, "  Netname: " . $iana->netname();
		push @reply, "  Descr: "   . $iana->descr();
		push @reply, "  Status: "  . $iana->status();
		push @reply, "  Source: "  . $iana->source();
		push @reply, "  Server: "  . $iana->server();
		push @reply, "  Inetnum: " . $iana->inetnum();

		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @reply;
	};

	return 0;
}

