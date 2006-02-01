package plugin::Mew;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^(mews?\s*)+\b/i ||
					$event->{command} =~ /^(mews?\s*)+$/i;

	return 0 if int(rand(2)) == 1;

	$self->{talker}->whisper(
			$event->{list} ? $event->{list} : $event->{person},
			'mew',
		);

	return "mewed like a cat";
}

1;

