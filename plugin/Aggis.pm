package plugin::Aggis;
use base plugin;
use strict;

our $DESCRIPTION = 'Describe what the given aggregate means';
our %CMDHELP = (
		'aggis ip_prefix[/prefix_length]' => 'Return output of aggis -d -D -T ip_prefix[/prefix_length]',
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
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

