package plugin::Pook;
use base plugin;
use strict;

our $DESCRIPTION = 'Pooks like a fish when other people do';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
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

