package plugin::AutoListJoin;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless ($event->{msgtype} eq 'LISTINVITE' && defined($event->{respond}));

	$self->{talker}->say($event->{respond});

	return "Auto-joined a list with: $event->{respond}";
}

1;

