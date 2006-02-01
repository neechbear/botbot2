package plugin::ZZZDumper;
use base plugin;
use strict;
use Data::Dumper;

sub handle {
	my ($self,$event,$responded) = @_;
	return if $event->{alarm};

	if ($event->{type} eq 'TELL' && $event->{command} eq 'debug') {
		while (my ($plugin,$response) = each %{$responded}) {
			$self->{talker}->whisper($event->{person},
					"$plugin responded: $response\n");
		}

		for ($self,$event,$responded) {
			$self->{talker}->whisper($event->{person},
					Dumper($_));
		}
	}

	# Shhh, I didn't do anything - honest.
	# I'm an invisible debugging plugin ;-)
	return 0;
}

1;

