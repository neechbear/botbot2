package plugin::helloworld;
use base plugin;
use strict;
use Data::Dumper;

sub handle {
	my ($self,$event,$responded) = @_;

	warn Dumper($event);
	warn Dumper($responded);
	warn Dumper($self);

}

1;

