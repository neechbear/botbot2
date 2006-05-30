package plugin::GoogleSets;
use base plugin;
use strict;
use WebService::Google::Sets;

our $DESCRIPTION = 'Google Sets';
our %CMDHELP = (
		'googleset <item1,item2..> ' => 'Return a full Google set for <item1,item2..>'
	);

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{'alarm'};
	return unless $event->{command} =~ /^(googlesets?)$/i;
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|LISTTALK|TELL$/;

	return 0 unless length($event->{cmdargs}->[0]);
	my $list = WebService::Google::Sets::get_gset(@{$event->{cmdargs}});

	if (defined($list) && ref($list) eq 'ARRAY' && @{$list}) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				join(', ', @{$list})
			);
		return "Returned a full Google set for @{$event->{cmdargs}";

	} else {
		$self->{talker}->whisper(
				$event->{person},
				'Erm, are they related at all?'
			);
		return 0;
	}
}

1;

