package URLTools;

use strict;
use LWP::UserAgent;
use HTML::Entities;
use HTML::Strip;
use Image::Info;
use File::Type;
use Tie::TinyURL "0.02";
use Socket;
use Exporter;

use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(getHtmlTitle tinyURL isIP resolve ip2host host2ip UserAgent html2text);
@EXPORT = @EXPORT_OK;

my %tinyurl = ();
tie %tinyurl, 'Tie::TinyURL', 'timeout' => 4;

sub getHtmlTitle {
	my $url = shift || undef;
	return '[No title information available]' unless defined $url;

	my $ua = UserAgent();

	# Go and get the URL they spoke about
	my $response = $ua->get($url);
	my $title = '';
	if ($response->is_success) {
		my $content = $response->content();
		($title) = $content =~ /<title>(.*?)<\/title>/si;
		$title = html2text($title) if $title;
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

sub UserAgent {
	my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050718 Firefox/1.0.4 (Debian package 1.0.4-2sarge1)',
			max_size => 102400,
			timeout => 4,
		);
	return $ua;
}

sub html2text {
	my @out = @_;
	my $hs = HTML::Strip->new();
	for (@out) {
		$_ = $hs->parse($_);
		$_ = HTML::Entities::decode($_);
		s/\n/ /gs; s/\s\s+/ /g;
	}
	return wantarray ? @out : "@out";
}

sub tinyURL {
	my $url = shift || undef;
	return $url if !defined($url) ||
		$url =~ m#^https?://(www\.)?tinyurl\.com/[\w\d]+#i;
	return $tinyurl{$url};
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

