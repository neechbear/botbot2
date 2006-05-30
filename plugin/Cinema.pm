package plugin::Cinema;
use base plugin;
use strict;
use URLTools;
use HTML::Strip;
use URI::Escape;
use Colloquy::Data qw(:all);

our $DESCRIPTION = 'Return movie show times are local cinemas';
our %CMDHELP = (
		'cinema <movie title>, <location>' => 'List showing times of <movie> at <location>'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;
	return unless $event->{command} =~ /^(cinema)$/i;

	my $arg = join(' ',@{$event->{cmdargs}});
	$arg =~ s/^\s+|\s+$//g;
	my ($movie,$location) = $arg =~ m/^\s*
			(.+?)(?:,\s*([^,]+))?
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

	sub uri_escape2 {
		local $_ = shift;
		s/\s+/+/g;
		return $_;
	}

	#my $url = sprintf('http://www.google.co.uk/movies?oi=showtimesm&hl=en&near=%s&dq=%s',
	my $url = sprintf('http://www.google.co.uk/movies?hl=en&near=%s&q=%s',
					uri_escape2($location), uri_escape2($movie));
	my $ua = UserAgent();
	my $response = $ua->get($url);

	if (!$response->is_success()) {
		$self->{talker}->whisper($event->{person},
				"Sorry; I couldn't find any appropriate showings of $movie"
			);
		return 0;
	}

	my $html = $response->content();
	$html =~ s/(<\/td>)/$1\n/ig;
	my $hs = HTML::Strip->new();
	my $clean_text = $hs->parse($html);
	$clean_text =~ s/\s*\n\s*\n\s*/\n/g;
	my @reply = ();
	for (split(/(\s*\n\s*)+/,$clean_text)) {
		if (/ - Map \d\d?:/) {
			s/ - Map (\d\d?:)/ - $1/;
			push @reply, $_;
		}
	}

	unless (@reply) {
		$self->{talker}->whisper($event->{person},
				"Sorry; I couldn't find any appropriate showings of $movie"
			);
		return 0;
	}

	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$_
		) for @reply[0..3];

	return "Returned weather information for $arg";
}

1;


