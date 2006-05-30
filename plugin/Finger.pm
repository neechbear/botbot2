package plugin::Finger;
use base plugin;
use strict;
use Net::Finger;

our $DESCRIPTION = 'Finger people';
our %CMDHELP = (
		'figer <user@host>' => 'Return finger results for <user@host>'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^finger$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;

	return 0 unless length($event->{cmdargs}->[0]);

	my @response = ();
	eval {
		@response = finger($event->{cmdargs}->[0]);
	};

	if (@response) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @response;
		return "Returned finger results for $event->{cmdargs}->[0]";
	}

	$self->{talker}->whisper(
			$event->{person},
			"Don't know who they are $@"
		);
	return 0;
}

1;

