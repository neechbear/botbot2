package plugin::ListPlugins;
use base plugin;
use strict;

our $DESCRIPTION = 'Returns a list of loaded botbot plugins';
our %CMDHELP = (
		'list plugins' => 'Display a list of loaded plugins'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;
	return unless $event->{text} =~ /^list\s*plugins?\s*$/i;

	for my $plugin (grep(/^plugin\//,sort(keys(%INC)))) {
		(my $ns = $plugin) =~ s/\//::/g;
		$ns =~ s/\.pm//;
		my $desc = eval("\$${ns}::DESCRIPTION") || '';
		$self->{talker}->whisper(
				$event->{list} ? $event->{list} : $event->{person},
				$plugin . ( $desc ? " - $desc" : '' )
			);
	}

	return "Returned a list of all loaded botbot plugins";
}

1;

