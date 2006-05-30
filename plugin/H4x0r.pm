package plugin::H4x0r;
use base plugin;
use strict;

sub handle {
	my ($self,$event) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
	return unless $event->{text} =~ /\`.+\`/;
	$self->say(".kick $event->{person} ooooo j00 l33t h4x0r j00");

	return "Kicked $event->{person} for trying to be a l33t h4x0r";
}

1;

