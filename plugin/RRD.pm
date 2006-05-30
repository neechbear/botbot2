package plugin::RRD;
use base plugin;
use strict;
use integer;
use RRD::Simple 1.32;

our $DESCRIPTION = 'Log talker usage statistics to an RRD file';

sub handle {
	my ($self,$event,$responded) = @_;

	$self->{chunk} = (time()/60)*60;
	$self->{lastchunk} ||= $self->{chunk};

	$self->{rrdfile} ||= './data/activity.rrd';
	$self->{rrd} ||= new RRD::Simple;

	$self->{counter} ||= {GROUP => 0, PRIVATE => 0, SHOUT => 0, LIST => 0};
	$self->{alarmcounter} ||= 0;

	$self->{alarmcounter}++ if $event->{'alarm'};
	if ($event->{'alarm'} && $self->{alarmcounter} > 30) {
		$self->{rrd}->graph($self->{rrdfile},
				destination => './data/',
				title => 'Talker Activity',
				width => 560,
				vertical_label => 'Messages per minute',
#				slope_mode => undef,
				units_exponent => 0,
#				interlaced => undef,
				line_thickness => 1,
				source_labels => {
						GROUP => '@Public',
						SHOUT => '!shouts',
						LIST => '%lists',
						PRIVATE => '>BotBot',
					},
				source_colors => {
						GROUP => '0000cc',
						SHOUT => 'cc0000',
						LIST => '00cc00',
						PRIVATE => 'ffd700',
					},
				color => [ (
						'BACK#d5e5FF',
						'SHADEA#C8C8FF',
						'SHADEB#9696BE',
						'ARROW#61B51B',
						'GRID#404852',
						'MGRID#67C6DE',
					) ],
			) if -f $self->{rrdfile};
		$self->{alarmcounter} = 0;
	}

	return unless $event->{msgtype} =~ /^(OBSERVE|TALK|TELL|SHOUT|LIST)/;
	$self->{counter}->{GROUP}++   if $event->{msgtype} =~ /^(OBSERVE|TALK)/;
	$self->{counter}->{PRIVATE}++ if $event->{msgtype} eq 'TELL';
	$self->{counter}->{LIST}++    if $event->{msgtype} =~ /^LIST/;
	$self->{counter}->{SHOUT}++   if $event->{msgtype} eq 'SHOUT';

	unless (-f $self->{rrdfile}) {
		$self->{rrd}->create($self->{rrdfile},
				GROUP   => 'GAUGE',
				PRIVATE => 'GAUGE',
				LIST    => 'GAUGE',
				SHOUT   => 'GAUGE',
			);
	}

	if ($self->{lastchunk} ne $self->{chunk}) {
		eval {
			$self->{rrd}->update($self->{rrdfile},$self->{chunk},
					map { $_ => $self->{counter}->{$_} } keys %{$self->{counter}}
				);
		};
		$self->{counter} = {GROUP => 0, PRIVATE => 0, SHOUT => 0, LIST => 0};
	}

	$self->{lastchunk} = $self->{chunk};

	return 0;
}

1;

__END__

