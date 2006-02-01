package plugin::Mew;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return undef unless int(rand(3)) == 2;
	return unless $event->{command} =~ /^(mews?\s*)+\b/i ||
					$event->{command} =~ /^(mews?\s*)+$/i;

	if (int(rand(3)) == 2) {
		$self->{talker}->say(
				($event->{list} !~ /\@/ ? "<<$event->{list}" : '<@Public')." ".
				"purrs"
			);
	} else {
		$self->{talker}->say(
				($event->{list} !~ /\@/ ? ">>$event->{list}" : '>@Public')." ".
				"mew"
			);
	}

	return "mewed like a cat";
}

1;

