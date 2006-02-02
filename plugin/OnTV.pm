package plugin::OnTV;
use base plugin;
use strict;
use XML::Simple;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{command} =~ /^ontv$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	my $talker = $self->{talker};

	return 0 unless length($event->{cmdargs}->[0]);
	my $str = join(' ',@{$event->{cmdargs}});

	my $xs = new XML::Simple();
	my $listings = $xs->XMLin("../data/blebtv/data.xml",
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

1;

