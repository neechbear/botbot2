package plugin::HelloWorld;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^traceroute|tracert$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]);
	my $ip = isIP($event->{cmdargs}->[0]) ? $event->{cmdargs}->[0] :
				(host2ip($event->{cmdargs}->[0]))[0];

	unless (isIP($ip)) {
		$talker->whisper(
				$event->{person},
				"Sorry; $event->{cmdargs}->[0] isn't a valid host/IP"
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

1;

