package plugin::IMDB;
use base plugin;
use strict;
use URLTools;
use HTML::Strip;
use LWP::UserAgent;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^imdb|imdbquote|movie|moviequote$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	# Create an LWP object to work with
	my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050718 Firefox/1.0.4 (Debian package 1.0.4-2sarge1)',
			timeout => 10
		);

	# Get the IMDB ID reference
	my $id;
	if (defined $event->{cmdargs}->[0] && $event->{cmdargs}->[0] =~ /^\d{7}$/) {
		$id = $event->{cmdargs}->[0];
	} else {
		my ($popular,@matches) = searchIMDB(join(' ', @{$event->{cmdargs}}));
		warn $_ for @matches;
		if (@matches && $matches[0] =~ /\s*(\d{7})\s*/) {
			$id = $1;
			warn $id;
		}
	}

	# Lookup a specific IMDB ID reference
	if ($id =~ /^\d{7}$/) {
		my $response = $ua->get("http://www.imdb.com/title/tt$id/quotes");
		my $html = '';
		if ($response->is_success) {
			$html = $response->content;
		} else {
			$talker->whisper(
					$event->{person},
					'Sorry, IMDB did not return a valid page; '.$response->status_line
				);
			return 0;
		}

		unless ($html =~ /Memorable Quotes from/ && $html =~ /<a name="qt\d+">/) {
			$talker->whisper(
					$event->{person},
					'Sorry, IMDB did not return any quotes for that movie'
				);
			return 0;
		}

		$html =~ s/.*Memorable Quotes from .+?(\n|\cM)//gs;
		$html =~ s/<br>\s*<br>\s*<div\s*.*//gs;
		$html =~ s/<hr.+?>/---<br>/gs;
		$html =~ s/(\n|\cM)//gs;
		$html =~ s/<br>/\n/gs;

		my $hs = HTML::Strip->new();
		my @reply = split(/\n/,$hs->parse($html));
		$hs->eof;

		$talker->whisper(
				$event->{person},
				$_
			) for @reply;
	}

	return 0;
}

sub _imdb {
	my $talker = shift;
	my $event = { @_ };

	# Lookup a specific IMDB ID reference
	if (defined $event->{cmdargs}->[0] && $event->{cmdargs}->[0] =~ /^\d{7}$/) {
		my $id = $event->{cmdargs}->[0];
		my $movie = IMDB::Movie->new($id);

		my @reply;
		push @reply, sprintf('%s - %s (%s)',
						$id,
						$movie->title,
						$movie->year
					);

		push @reply, sprintf('  Director%s: %s',
						(@{$movie->director} == 1 ? '' : 's'),
						join(' / ',@{$movie->director})
					) if @{$movie->director};
		push @reply, sprintf('  Writer%s: %s',
						(@{$movie->writer} == 1 ? '' : 's'),
						join(' / ',@{$movie->writer})
					) if @{$movie->writer};
		push @reply, sprintf('  Genre%s: %s',
						(@{$movie->genres} == 1 ? '' : 's'),
						join(' / ',@{$movie->genres})
					) if @{$movie->genres};

		my $detailurl = tinyURL("http://www.imdb.com/title/tt$id/");
		push @reply, sprintf('  Details: %s',
						$detailurl
					) if defined $detailurl;

		my $quotesurl = tinyURL("http://www.imdb.com/title/tt$id/quotes");
		push @reply, sprintf('  Quotes: %s',
						$quotesurl
					) if defined $quotesurl;

		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @reply;

	# Search for titles
	} else {
		my ($recLimit,@matches) = searchIMDB(join(' ', @{$event->{cmdargs}}));
		$recLimit = 3 if $recLimit < 3;

		unless (@matches) {
			$talker->whisper(
					$event->{person},
					'Sorry, I failed to return an IMDB match for your query'
				);
		} else {
			unshift @matches, 'Showing '.(($#matches + 1) < $recLimit ?
					($#matches + 1) : $recLimit).' results out of '.($#matches + 1);
			for (my $i = 0; $i <= $recLimit; $i++) {
				$talker->whisper(
						($event->{list} ? $event->{list} : $event->{person}),
						$matches[$i]
					);
			}
		}
	}

	return 0;
}

sub searchIMDB {
	my $title = shift || undef;
	return undef unless defined $title;
	$title =~ s/\s+/%20/;
	my $url = sprintf('http://www.imdb.com/find?q=%s;s=tt', $title);

	# Create an LWP object to work with
	my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050718 Firefox/1.0.4 (Debian package 1.0.4-2sarge1)',
			timeout => 10
		);

	my @matches;
	my $popular = 0;
	my $response = $ua->get($url);
	if ($response->is_success) {
		for (split(/\n+/, $response->content)) {
			if ($_ =~ m#Popular Titles</b> \(Displaying (\d+) Results\)#) {
				$popular = $1;
			}
			if (m#href="/title/tt(\d+)/".*?>(.+?)</a>(.+?)</li>#) {
				my ($id,$title,$extra) = ($1,$2,$3);
				my ($year,$type) = ('','');
				($year) = $extra =~ m/\((\d{4})\)/;
				($type) = $extra =~ m/\(([A-Za-z]+)\)/;
				my $reply = "  $id - ".HTML::Entities::decode_entities($title);
				$reply .= " ($year)" if $year;
				$reply .= " ($type)" if $type;
				push @matches, $reply;
			}
		}
		return ($popular,@matches);
	}

	return undef;
}

1;

