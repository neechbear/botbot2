package plugin::Mew;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
	return undef unless int(rand(3)) == 2;
	return unless $event->{args}->[0] =~ /^(p+u+r+s*|m+e+w+s*|m+e+o*w+s?\s*)+\b/i ||
					$event->{args}->[0] =~ /^(p+u+r+s*|m+e+w+s*|m+e+o*w+s?\s*)+$/i;

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

