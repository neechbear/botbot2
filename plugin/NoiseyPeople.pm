package plugin::NoiseyPeople;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return unless defined($event->{person});

	$self->{counter}->{$event->{person}} = 0
			unless defined($self->{counter}->{$event->{person}});

	if ($event->{'alarm'}) {
		$self->{counter}->{$event->{person}}--
			unless $self->{counter}->{$event->{person}} == 0;
	}

	my @words = @{$event->{args}};
	return unless @words > 4;

	my $uppercase_words = 0;
	for my $word (@words) {
		$uppercase_words++ if ($word =~ /[a-z]/i && uc($word) eq $word);
	}

	if ( ( ($uppercase_words / @words) * 100) > 80
			&& $self->{counter}->{$event->{person}} <= 0) {
		$self->{counter}->{$event->{person}} = 4;

		if ($event->{person} =~ /zoe/i) {
			$self->{talker}->say(
					($event->{list} !~ /\@/ ? "<$event->{list}" : '<@Public')." ".
					"comforts $event->{person}. there there, shhhhhh it'll be okay"
				);
		} else {
			$self->{talker}->say(
					($event->{list} !~ /\@/ ? ">$event->{list}" : '>@Public')." ".
					"SHHHHHH!"
				);
		}
	}
}

1;

