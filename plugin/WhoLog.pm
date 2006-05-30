package plugin::WhoLog;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	$self->{countdown} = 1 unless defined($self->{countdown});

	if ($event->{'msgtype'} eq 'ALRM') {
		$self->{countdown} ||= 6;
		$self->{countdown}--;
		if ($self->{countdown} == 0) {
			$self->{talker}->say('.who');
		}

	} elsif ($event->{msgtype} =~ /^WHO(HDR)?$/) {
		my $mode = /Users on .+ at the moment/ ? '>' : '>>';
		my $file = "./data/who.log";
		if (open(FH, $mode, $file)) {
			print FH "$event->{text}\n";
			close(FH);
		} else {
			warn "Unable to open file handle FH for file '$file': $!";
		}
	}
}

1;

