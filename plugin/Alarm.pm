package plugin::Alarm;
use base plugin;
use strict;

our $DESCRIPTION = 'NOOP';
our %CMDHELP = ();

sub handle {
	my ($self,$event,$responded) = @_;
	if ($event->{'msgtype'} eq 'ALRM') {
		# I'm not actually doing anything really
		#warn "ALARM\n";
		#use Data::Dumper;
		#warn Dumper(\%INC);
	}
	return 0;
}

1;

