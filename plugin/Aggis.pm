package plugin::Aggis;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^aggis$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	return 0 unless defined($event->{cmdargs}->[0]) && length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});
	return 0 unless $str =~ /^[0-9\.\-\/ ]+$/;

	$self->{talker}->whisper(
			$event->{list} ? $event->{list} : $event->{person},
			$_
		) for split(/\n/,`aggis -d -D -T $str`);

	return "Returned aggis output for $str";
}

1;

