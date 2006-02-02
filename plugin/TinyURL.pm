package plugin::HelloWorld;
use base plugin;
use strict;
use LWP::UserAgent;
use HTML::Entities;
use HTML::Strip;
use Image::Info;
use File::Type;
use Socket;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|OBSERVE EMOTE|EMOTE|TALK|TELL|LISTEMOTE|LISTTALK$/;

	my $talker = $self->{talker};

	# Extract the URL from what they said
	my $url = '';
	if ($event->{raw} =~ /\b((https?:\/\/|www\.)\S+)\b/i) {
		$url = $1;
	}
	$url = "http://$url" unless $url =~ /^https?:\/\//i;

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
	if (open(FH, "./data/url.log")) {
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

sub getHtmlTitle {
	my $url = shift || undef;
	return '[No title information available]' unless defined $url;

	# Create an LWP object to work with
	my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050718 Firefox/1.0.4 (Debian package 1.0.4-2sarge1)',
			max_size => 102400,
			timeout => 10
		);

	# Go and get the URL they spoke about
	my $response = $ua->get($url);
	my $title = '';
	if ($response->is_success) {
		my $content = $response->content();
		($title) = $content =~ /<title>(.*?)<\/title>/si;
		if ($title) {
			my $hs = HTML::Strip->new();
			$title = $hs->parse($title);
			$title = HTML::Entities::decode($title);
			$title =~ s/\n/ /gs; $title =~ s/\s\s+/ /g;
		}
		if (!$title) {
			eval {
				my $info = Image::Info::image_info(\$content);
				my($w, $h) = Image::Info::dim($info);
				if ($w && $h) {
					$title = "$info->{file_media_type} ${w}x${h}";
					if (exists $info->{BitsPerSample}->[0]) {
						$title .= " (".sum(@{$info->{BitsPerSample}})." bit)";
					}
				}
			};
			if ($@ || !$title) {
				eval {
					my $ft = File::Type->new();
					$title = $ft->checktype_contents($content);
				};
			}
		}
	} else {
		return ('',$response);
	}

	sub sum {
		my $x = 0;
		for (@_) { $x += $_; };
		return $x;
	}

	$title = '[No title information available]'
		if !defined $title || $title =~ /^\s*$/;

	return ($title,$response);
}

sub tinyURL {
	my $url = shift || undef;
	return undef unless defined $url;

	my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050718 Firefox/1.0.4 (Debian package 1.0.4-2sarge1)',
			timeout => 10
		);

	my $shorturl = $url;
	unless ($shorturl =~ m#^https?://(tinyurl\.com|shrunk\.net)/[\w\d]+/?#i) {
		my $response = $ua->get("http://tinyurl.com/create.php?url=$url");
		return undef unless $response->is_success;
		if ($response->content =~ m|<input type=hidden name=tinyurl value="(http://tinyurl.com/[a-zA-Z0-9]+)">|) {
			$shorturl = $1;
		}
	}

	return $shorturl;
}

sub ip2host {
	my $ip = shift;
	my @numbers = split(/\./, $ip);
	my $ip_number = pack("C4", @numbers);
	my ($host) = (gethostbyaddr($ip_number, 2))[0];
	if (defined $host && $host) {
		return $host;
	} else {
		return $ip;
	}
}

sub isIP {
	return 1 if $_[0] =~ /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.
							(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.
							(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.
							(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/x;
	return 0;
}

sub resolve {
	return ip2host(@_) if isIP($_[0]);
	return host2ip(@_);
}

sub host2ip {
	my $host = shift;
	my @addresses = gethostbyname($host);
	if (@addresses > 0) {
		@addresses = map { inet_ntoa($_) } @addresses[4 .. $#addresses];
		return @addresses;
	} else {
		return $host;
	}
}

1;

