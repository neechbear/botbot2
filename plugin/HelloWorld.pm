package plugin::HelloWorld;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /wassup|yo|hi'?ya|hi|hello/i;
	return unless $event->{msgtype} eq 'TELL';

	$self->{talker}->whisper(
			$event->{list} ? $event->{list} : $event->{person},
			"Hello $event->{person}, you slag!",
		);

	return "I said hello";
}

1;

