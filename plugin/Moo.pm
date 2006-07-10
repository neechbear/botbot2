package plugin::Moo;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
	return undef unless int(rand(3)) == 2;
	return unless $event->{args}->[0] =~ /^(m+oo+s*|b+aa+s*)+\b/i ||
					$event->{args}->[0] =~ /^(m+oo+s*|b+aa+s*)+$/i;

	if (int(rand(3)) == 2) {
		$self->{talker}->say(
				($event->{list} !~ /\@/ ? "<<$event->{list}" : '<@Public')." ".
				(int(rand(5)) == 3 ? 'baaaaaaas' : "moos")
			);
	} else {
		$self->{talker}->say(
				($event->{list} !~ /\@/ ? ">>$event->{list}" : '>@Public')." ".
				(int(rand(5)) == 3 ? 'baa' : "moo")
			);
	}

	return "mewed like a cat";
}

1;

