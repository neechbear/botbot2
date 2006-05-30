package plugin::GoogleCalc;
use base plugin;
use strict;
use WWW::Google::Calculator;

our $DESCRIPTION = 'Google Calculator';
our %CMDHELP = (
		'calc <expression> ' => 'Return results of <expression> using Google\'s calculator'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^(calc|expr|eval)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;

	return 0 unless length($event->{cmdargs}->[0]);
	my $query = join(' ',@{$event->{cmdargs}});

	my $calc = WWW::Google::Calculator->new;
	my $reply = $calc->calc($query);

	if (defined $reply && $reply) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$reply
			);
		return "Returned result of $query";

	} else {
		$self->{talker}->whisper(
				$event->{person},
				'I don\'t know'
			);
		return 0;
	}
}

1;

