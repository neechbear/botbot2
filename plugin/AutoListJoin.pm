package plugin::AutoListJoin;
use base plugin;
use strict;

our $DESCRIPTION = 'Automatically join lists';
our %CMDHELP = ();

sub handle {
	my ($self,$event,$responded) = @_;

	$self->{countdown} = 1 unless defined($self->{countdown});

	if ($event->{'msgtype'} eq 'ALRM') {
		$self->{countdown} ||= 100;
		$self->{countdown}--;
		if ($self->{countdown} == 0) {
			$self->{talker}->say('.lists');
		}

	} elsif ($event->{msgtype} =~ /^LISTINFOLIST|LISTS$/) {
		for my $list (grep(!/^(\*|\+)/,@{$event->{args}})) {
			$self->{talker}->say(".list join $list");
		}

	} elsif ($event->{msgtype} eq 'LISTINVITE' && defined($event->{respond})) {
		$self->{talker}->say($event->{respond});
		return "Auto-joined a list with: $event->{respond}";
	}
}

1;

