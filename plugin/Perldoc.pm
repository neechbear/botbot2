package plugin::Perldoc;
use base plugin;
use strict;
use Colloquy::Data qw(:all);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^perldoc$/i;
	return unless $event->{msgtype} eq 'TELL';

	my $pod = $event->{cmdargs}->[0];
	return 0 unless defined($pod) && $pod =~ /^[a-zA-Z0-9\:]+$/i;

	my $colloquy_datadir = "/home/system/colloquy/data";
	my ($users_hashref,$lists_hashref) = users($colloquy_datadir);
	my $width = $users_hashref->{$event->{person}}->{width} || 79;
	$width -= 14;

	my $text = `perldoc -T -t -w width:$width $pod`;

	$self->{talker}->whisper(
			$event->{list} ? $event->{list} : $event->{person},
			$_
		) for split(/\n/,$text);

	return "Returned the POD for $pod";
}

1;

