package plugin::Alarm;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;
	if ($event->{'alarm'}) {
		# I'm not actually doing anything really
		#warn "ALARM\n";
		#use Data::Dumper;
		#warn Dumper(\%INC);
	}
	return 0;
}

1;

