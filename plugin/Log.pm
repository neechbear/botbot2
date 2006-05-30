package plugin::Log;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;
	return if $event->{'alarm'};

	$self->log($event->{raw});

	# Didn't respond to the user
	return 0;
}

1;

