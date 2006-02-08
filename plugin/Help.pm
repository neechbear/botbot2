package plugin::Help;
use base plugin;
use strict;
use vars qw($DESCRIPTION);

$DESCRIPTION = 'BotBot and plugin help for commands';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} eq 'TELL';
	return unless $event->{text} =~ /^help/i;

	for my $plugin (grep(/^plugin\//,sort(keys(%INC)))) {
		(my $ns = $plugin) =~ s/\//::/g;
		$ns =~ s/\.pm//;

		my $desc = eval("\$${ns}::DESCRIPTION") || '';
		my %commands = eval("\%${ns}::CMDHELP");
		next unless keys(%commands);

		$self->{talker}->whisper(
				$event->{list} ? $event->{list} : $event->{person},
				$plugin . ( $desc ? " - $desc" : '' )
			);

		for my $command (sort(keys(%commands))) {
			$self->{talker}->whisper(
					$event->{list} ? $event->{list} : $event->{person},
					"   $command - $commands{$command}"
				);
		}
	}

	return "Returned a help for a list of botbot plugin commands";
}

1;

