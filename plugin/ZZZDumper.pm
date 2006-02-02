package plugin::ZZZDumper;
use base plugin;
use strict;
use Data::Dumper;

sub handle {
	my ($self,$event,$responded) = @_;
	return if $event->{alarm};
	return if $event->{msgtype} =~ /^DONE/;

	if ($event->{msgtype} eq 'TELL' && $event->{command} eq 'debug' &&
			$event->{person} =~ /^heds|jen|neech$/i) {
		if (defined $event->{cmdargs}->[0] &&
				$event->{cmdargs}->[0] =~ /^[1-9][0-9]*$/) {
			$self->{debug_counter} = $event->{cmdargs}->[0];
		}
		$self->{debug_counter} ||= 1;
		$self->{debug_person} = $event->{person};
	}

	if (defined $self->{debug_counter} && $self->{debug_counter}) {
		while (my ($plugin,$response) = each %{$responded}) {
			$self->{talker}->whisper($self->{debug_person},
					"$plugin responded: $response\n");
		}

		#for ($self,$event,$responded) {
		for ($event) {
			$self->{talker}->whisper($self->{debug_person},$_)
				for split(/\n/,Dumper($_));
		}

		$self->{debug_counter}--;
	}

	# Shhh, I didn't do anything - honest.
	# I'm an invisible debugging plugin ;-)
	return 0;
}

1;

