package plugin::Pook;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return undef unless int(rand(3)) == 2;
	return unless $event->{command} =~ /^(poo+ks?\s*)+\b/i ||
					$event->{command} =~ /^(poo+ks?\s*)+$/i;

	if (int(rand(3)) == 2) {
		$self->{talker}->say(
				($event->{list} !~ /\@/ ? "<<$event->{list}" : '<@Public')." ".
				"pooks"
			);
	} else {
		$self->{talker}->say(
				($event->{list} !~ /\@/ ? ">>$event->{list}" : '>@Public')." ".
				"pook"
			);
	}

	return "pooked like a fish";
}

1;

