package plugin::TinyURL;
use base plugin;
use strict;
use URLTools;

our $DESCRIPTION = "Shortens URLs to 'TinyURL's and displays web site titles";

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'msgtype'} eq 'ALRM';
	return unless $event->{msgtype} =~ /^OBSERVE TALK|OBSERVE EMOTE|EMOTE|TALK|TELL|LISTEMOTE|LISTTALK$/;
	return unless ($event->{text} =~ /https?:\/\/\S+/i || $event->{text} =~ /\bwww\.\S+/i);

	my $talker = $self->{talker};

	# Extract the URL from what they said
	my $url = '';
	if ($event->{raw} =~ /\b((https?:\/\/|www\.)\S+)\b/i) {
		$url = $1;
	}
	$url = "http://$url" unless $url =~ /^https?:\/\//i;
	return 0 if length($url) < 70 && $self->{config}->{ignore_short_urls};

	# Check that the URL at least has a valid hostname or IP address
	if ($url =~ /https?:\/\/(?:\w+?:\w+?@)?([a-zA-Z0-9-\.]+)(:\d+)?/) {
		my $str = $1;
		if (!isIP($str) && host2ip($str) eq $str) {
			if ($event->{msgtype} eq 'TELL') {
				$talker->whisper(
						$event->{person},
						"I don't think $str is a valid hostname within that URL."
					);
			}
			return 0;
		}
	}

	# Go and get the URL they spoke about
	my ($title,$response) = getHtmlTitle($url);
	if (!$title) {
		$title = "[".$response->status_line."]";
		$talker->whisper(
				$event->{person},
				'That URL does not return a valid webpage; '.$response->status_line
			);
	}

	# Go and get the TinyURL
	my $shorturl = tinyURL($url) || $url;

	$talker->whisper(
			$event->{person},
			'Sorry, I failed to convert that to a TinyURL'
		) unless defined $shorturl;

	# Respond
	my $reply = " $shorturl - $title";
	$talker->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			$reply
		);

	# Write the URL to our log
	if (open(FH, ">>./data/url.log")) {
		$title =~ s/\s+/ /g;
		$title = '' if $title eq '[No title information available]';
		$shorturl = '' if $shorturl eq $url;
		print FH sprintf("%d\t%s\t%s\t%s\t%s\t%s\n",
			time(), $event->{person}, $url, $shorturl, $event->{list}, $title);
		close(FH);
	} else {
		warn "Unable to open file handle FH for file './data/url.log': $!";
	}

	return 0;
}

1;

