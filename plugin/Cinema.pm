package plugin::Cinema;
use base plugin;
use strict;
use URLTools;
use HTML::Strip;
use URI::Escape;
use Colloquy::Data qw(:all);

our $DESCRIPTION = 'Return movie show times are local cinemas';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;
	return unless $event->{command} =~ /^(cinema)$/i;

	my $arg = join(' ',@{$event->{cmdargs}});
	$arg =~ s/^\s+|\s+$//g;
	my ($movie,$location) = $arg =~ m/^\s*
			(.+?)(,[^,]+)?
		\s*$/ix;

	unless ($location) {
		my $colloquy_datadir = "/home/system/colloquy/data";
		my ($users_hashref,$lists_hashref) = users($colloquy_datadir);
		$location = $users_hashref->{$event->{person}}->{location}
					|| 'London, United Kingdom';
	}

	unless ($location =~ /\s+/ || $location =~ /,/) {
		$location .= ', United Kingdom';
	}

	my $url = sprintf('http://www.google.co.uk/movies?oi=showtimesm&hl=en&near=%s&dq=%s',
					uri_escape($location), uri_escape($movie));
	my $ua = UserAgent();
	my $response = $ua->get($url);

	if (!$response->is_success()) {
		$self->{talker}->whisper($event->{person},
				"Sorry; I couldn't find any appropriate showings of $movie"
			);
		return 0;
	}

	my @reply = ();
	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$_
		) for @reply;

	return "Returned weather information for $arg";
}

1;

