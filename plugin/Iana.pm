package plugin::Iana;
use base plugin;
use strict;
use URLTools;
use Net::Whois::IANA;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^(iana|whois)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]) && isIP($event->{cmdargs}->[0]);
	my $ip = $event->{cmdargs}->[0];

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
		return "Returned a Net::Whois::IANA for $ip";
	};

	return 0;
}

1;

