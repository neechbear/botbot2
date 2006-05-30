package plugin::AutoListJoin;
use base plugin;
use strict;

our $DESCRIPTION = 'Automatically join lists';
our %CMDHELP = ();

sub handle {
	my ($self,$event,$responded) = @_;

	$self->{'last_probed'} = 0 unless defined($self->{'last_probed'});

	if ($event->{'msgtype'} eq 'ALRM') {
		if (time() - $self->{'last_probed'} > 300) {
			$self->{'last_probed'} = time();
			$self->say('.lists');
		}

	} elsif ($event->{msgtype} =~ /^LISTINFOLIST|LISTS$/) {
		for my $list (grep(!/^(\*|\+)/,@{$event->{args}})) {
			$self->say(".list join $list");
		}

	} elsif ($event->{msgtype} eq 'LISTINVITE' && defined($event->{respond})) {
		$self->say($event->{respond});
		return "Auto-joined a list with: $event->{respond}";
	}
}

1;

