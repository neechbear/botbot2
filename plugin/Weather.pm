package plugin::Weather;
use base plugin;
use strict;
use Weather::Cached;

our $DESCRIPTION = 'Return weather information from weather.com';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;
	return unless $event->{command} =~ /^weather|forecast$/i;

	my $cachedir = './data/weathercache/';
	mkdir $cachedir unless -e $cachedir;
	my %params = (
			'cache'      => $cachedir,
			'current'    => $event->{command} =~ /^weather$/i ? 1 : 0,
			'forecast'   => $event->{command} =~ /^fore?cast$/i ? 2 : 0,
			'links'      => 1,
			'units'      => 's',
			'timeout'    => 5,
			'debug'      => 0,
			'partner_id' => 'somepartnerid',
			'license'    => '12345678',
		);

	my $cached_weather = Weather::Cached->new(%params);
	my $arg = join(' ',@{$event->{cmdargs}});

	if (my $locations = $cached_weather->search($arg)) {

		# I know, ... i might do something other than just return one day
		foreach (keys %{$locations}) {
			my $weather = $cached_weather->get_weather($_);
			my @reply = ();

			# Forecast
			if ($event->{command} =~ /^fore?cast$/i) {
				my $tomorrow = $weather->{dayf}->{day}->[1];
				my $str = sprintf('%s, %s: %s, hi %s %s / low %s %s',
						$tomorrow->{dt},
						$weather->{loc}->{dnam}, $tomorrow->{part}->[0]->{t},
						$tomorrow->{hi}, $weather->{head}->{ut},
						$tomorrow->{low}, $weather->{head}->{ut},
					);
				$str .= sprintf('. %s %s %s wind',
						$tomorrow->{part}->[0]->{wind}->{s}, $weather->{head}->{us},
						$tomorrow->{part}->[0]->{wind}->{t}, 
					);
				push @reply, $str;

			# Current conditions
			} else {
				my $str = sprintf('%s: %s, temp %s %s',
						$weather->{loc}->{dnam}, $weather->{cc}->{t},
						$weather->{cc}->{tmp}, $weather->{head}->{ut},
					);
				$str .= sprintf(', (feels like %s %s)',
						$weather->{cc}->{flik}, $weather->{head}->{ut},
					) if $weather->{cc}->{flik} != $weather->{cc}->{tmp};
				$str .= sprintf('. %s %s %s wind',
						$weather->{cc}->{wind}->{s}, $weather->{head}->{us},
						$weather->{cc}->{wind}->{t}, 
					);
				push @reply, $str;
			}

			$self->{talker}->whisper(
					($event->{list} ? $event->{list} : $event->{person}),
					$_
				) for @reply;
			return "Returned weather information for @{$event->{cmdargs}}";
		}

	} else {
		$self->{talker}->whisper($event->{person},
				"I don't know where $arg is; try another location?"
			);
		return 0;
	} 
}

1;

