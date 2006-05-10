package plugin::Help;
use base plugin;
use strict;

our $DESCRIPTION = 'BotBot and plugin help for commands';
our %CMDHELP = (
		'help' => 'Display basic help information',
		'help all' => 'Display help for all commands and plugins'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} eq 'TELL';
	return unless $event->{text} =~ /^help/i;

	if ($event->{text} =~ /^help\s+(\S+)/i) {
		my $type = lc($1);

		if ($type =~ /^(everything|all|plugins)$/) {
			for my $plugin (grep(/^plugin\//,sort(keys(%INC)))) {
				plugin_help($self,$event,$plugin);
			}
			return "Displayed help for all plugins";

		} elsif (my ($plugin) = grep(/^(plugin\/)?$type(\.pm)?$/i,keys(%INC))) {
			return unless $plugin;
			plugin_help($self,$event,$plugin);
			return "Displayed help for the $type plugin";
		}
	}

	for my $line ((
				'Try "list plugins" to display a list of available plugins.',
				'Try "help <plugin> to display helpful information about a specific plugin.',
				'Try "help all" to display helpful information about all available plugins.'
			)) {
		$self->{talker}->whisper(
				$event->{list} ? $event->{list} : $event->{person},
				$line
			);
	}

	return "Returned some basic help";
}



sub plugin_help {
	my ($self,$event,$plugin) = @_;
	warn "plugin = $plugin";
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

1;

