package plugin::Man;
use base plugin;
use strict;
use Colloquy::Data qw(:all);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
	return unless $event->{command} =~ /^man$/i;
	return unless $event->{msgtype} eq 'TELL';

	my $man = $event->{cmdargs}->[0];
	return 0 unless defined($man) && $man =~ /^[a-zA-Z0-9\-_\:]+$/i;

	my $colloquy_datadir = "/home/system/colloquy/data";
	my ($users_hashref,$lists_hashref) = users($colloquy_datadir);
	my $width = $users_hashref->{$event->{person}}->{width} || 79;
	$width -= 14;

	my $text = `COLUMNS=$width man $man | cat`;

	$self->{talker}->whisper(
			$event->{list} ? $event->{list} : $event->{person},
			$_
		) for split(/\n/,$text);

	return "Returned the man page for $man";
}

1;

