package plugin::ZZZRestart;
use base plugin;
use strict;

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return if $event->{msgtype} ne 'TELL';
	return if $event->{command} !~ /^(restart|quit|shutdown|stop|die|exit|logout)$/i;
	return unless $event->{person} =~ /^(neech2?|jen|heds|tims)$/i;

	use FindBin qw($Bin);
	(my $SELF = $0) =~ s|^.*/||;

	warn("$Bin/$SELF -d -p \&");
	system("$Bin/$SELF -d -p \&") if $event->{command} =~ /^re/i;
	exit;

	return 0;
}

1;

