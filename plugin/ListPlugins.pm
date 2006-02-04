package plugin::ListPlugins;
use base plugin;
use strict;
use vars qw($DESCRIPTION);

$DESCRIPTION = 'Returns a list of loaded botbot plugins';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;
	return unless $event->{text} =~ /^list\s*plugins?\s*$/i;

	for my $plugin (grep(/^plugin\//,sort(keys(%INC)))) {
		my $desc = eval("\$${plugin}::DESCRIPTION") || '';
		$self->{talker}->whisper(
				$event->{list} ? $event->{list} : $event->{person},
				$plugin . ( $desc ? " - $desc" : '' )
			);
	}

	return "Returned a list of all loaded botbot plugins";
}

1;

