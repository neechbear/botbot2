package plugin::RRD;
use base plugin;
use strict;
use integer;

use RRD::Simple 1.34;
use RRDs;
$RRD::Simple::DEFAULT_DSTYPE = 'DERIVE';

our $DESCRIPTION = 'Log talker usage statistics to an RRD file';

sub handle {
	my ($self,$event,$responded) = @_;

	$self->{rrdfile} ||= './data/activity.rrd';
	$self->{rrd} ||= new RRD::Simple;
	$self->{counter} ||= {GROUP => 0, PRIVATE => 0, SHOUT => 0, LIST => 0};
	$self->{alarmcounter} ||= 0;
	$self->{alarmcounter}++ if $event->{'msgtype'} eq 'ALRM';

	if ($event->{'msgtype'} eq 'ALRM' && $self->{alarmcounter} > 30) {
		$self->{alarmcounter} = 0;

		eval {
			unless (-f $self->{rrdfile}) {
				$self->{rrd}->create($self->{rrdfile},
					GROUP   => 'DERIVE',
					PRIVATE => 'DERIVE',
					LIST    => 'DERIVE',
					SHOUT   => 'DERIVE',
				);
				RRDs::tune($self->{rrdfile},'-i',"$_:0") for
					$self->{rrd}->sources($self->{rrdfile});
			} else {
				$self->{rrd}->update($self->{rrdfile}, %{$self->{counter}});
			}

		$self->{rrd}->graph($self->{rrdfile},
#				width => 560,
#				slope_mode => undef,
#				interlaced => undef,
				destination => './data/',
				title => 'Talker Activity',
				vertical_label => 'Messages',
				units_exponent => 0,
				line_thickness => 1,
				sources => [ qw(GROUP LIST PRIVATE SHOUT) ],
				source_drawtypes => [ qw(AREA STACK STACK STACK) ],
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
		};
	}

	$self->{counter}->{GROUP}++   if $event->{msgtype} =~ /^(OBSERVE|TALK)/;
	$self->{counter}->{PRIVATE}++ if $event->{msgtype} eq 'TELL';
	$self->{counter}->{LIST}++    if $event->{msgtype} =~ /^LIST(TALK|EMOTE)/;
	$self->{counter}->{SHOUT}++   if $event->{msgtype} eq 'SHOUT';

	return 0;
}

1;

__END__

