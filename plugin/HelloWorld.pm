package plugin::HelloWorld;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;
	return if $event->{alarm};
	$self->{talker}->whisper(
			$event->{list} ? $event->{list} : $event->{person},
			"Hello $event->{person}, you slag!",
		);
	return "I spoke";
}

1;

