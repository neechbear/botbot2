package plugin::Login;
use base plugin;
use strict;

our $DESCRIPTION = 'Login to talker';
our %CMDHELP = ();

sub handle {
	my ($self,$event) = @_;

	$self->say(sprintf('%s%s %s',
			($self->{config}->{force_login} ? '*' : ''),
			$self->{config}->{username},
			$self->{config}->{password}
		)) if $event->{msgtype} eq 'HELLO' && !$self->{logged_in};

	if ($event->{msgtype} =~ /^DONE|COMMENT$/ && !$self->{logged_in}) {
		$self->{logged_in} = 1;
		$self->say(".observe Public");
	}
}

1;

