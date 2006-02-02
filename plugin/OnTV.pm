package plugin::OnTV;
use base plugin;
use strict;
use XML::Simple;
use LWP::Simple;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^ontv$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});

	if ((stat('./data/blebtv.xml'))[9] > time-(60*60*24)) {
		my @channels = qw(bbc1 bbc2 itv1 ch4 five abc1 bbc1_n_ireland
			bbc1_scotland bbc1_wales bbc2_n_ireland bbc2_scotland bbc2_wales
			bbc3 bbc4 bbc7 bbc_6music bbc_news24 bbc_parliament bbc_radio1
			bbc_radio1_xtra bbc_radio2 bbc_radio3 bbc_radio4 bbc_radio5_live
			bbc_radio5_live_sports_extra bbc_radio_scotland bbc_world_service
			boomerang bravo british_eurosport cartoon_network cbbc cbeebies
			challenge discovery discovery_kids discovery_real_time disney e4
			film_four ftn itv2 itv3 itv4 living_tv men_and_motors more4 mtv
			nick_junior nickelodeon oneword paramount paramount2 s4c scifi
			sky_cinema1 sky_cinema2 sky_movies1 sky_movies2 sky_movies3
			sky_movies4 sky_movies5 sky_movies6 sky_movies7 sky_movies8
			sky_movies9 sky_movies_cinema sky_movies_cinema2 sky_one
			sky_one_mix sky_sports1 sky_sports2 sky_sports3 sky_sports_news
			sky_sports_xtra sky_three sky_travel tcm uk_bright_ideas uk_drama
			uk_gold uk_history uk_style uktv_documentary uktv_people vh1);

		#my $url = 'http://www.bleb.org/tv/data/listings?days=0..6&format=XMLTV&channels=';
		my $url = 'http://www.bleb.org/tv/data/listings?days=0..2&format=XMLTV&channels=';
		$url .= join(',',grep(!/_(ireland|scotland|wales)$/,@channels));

		mirror($url, 'blebtv.zip');
		system('unzip -q -o ./data/blebtv.zip -d ./data');
	}

	my $xs = new XML::Simple();
	my $listings = $xs->XMLin("./data/data.xml",
						ForceArray => 1, KeyAttr => 'key');

	my %channels;
	for my $c (@{$listings->{channel}}) {
		$channels{$c->{id}} = $c->{'display-name'}->[0];
	}

	my $today = isodate(time);
	my $tomorrow = isodate(time + (60*60*24));

	my @reply;
	for my $p (@{$listings->{programme}}) {
		# Skip regional channels
		next if $p->{channel} =~ /_(ireland|scotland|wales)$/;

		# Only search today and tomorrow
		next if $p->{start} !~ /^($today|$tomorrow)/;

		if ($p->{title}->[0]->{content} =~ /$str/i) {
			my $prog = {
					title => $p->{title}->[0]->{content},
					desc => $p->{desc}->[0]->{content},
					start => isodate2prettydate($p->{start}),
					end => isodate2prettydate($p->{stop}),
					channel => $channels{$p->{channel}},
				};
			push @reply, sprintf('%s on %s:  %s  --  %s',
							$prog->{start},
#							$prog->{end},
							$prog->{channel},
							$prog->{title},
							$prog->{desc}
						);
		}
	}

	@reply = sort @reply;

	unless (@reply) {
		$talker->whisper(
				$event->{person},
				'Sorry, I couldn\'t find any matching TV programmes for you, showing today or tomorrow'
			);
	} elsif (($#reply + 1) > 10) {
		my $matches = $#reply + 1;
		$talker->whisper(
				$event->{person},
				"Sorry, searching for the programme '$str' returned more than 10 matches (found $matches matches)"
			);
	} else {
		$talker->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$_
			) for @reply;
	}

	return 0;
}

sub isodate {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(shift || time);
	$year += 1900;
	$mon++;
	return sprintf('%04d%02d%02d',$year,$mon,$mday);
}

sub isodate2prettydate {
	local $_ = shift || '';
	return $_ unless /^(\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/;
	return "$1/$2/$3 $4:$5";
}

1;

