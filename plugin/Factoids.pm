package plugin::Factoids;
use base plugin;
use strict;
use FactStore;

our $DESCRIPTION = 'InfoBot-like factoid plugin';

sub factstore {
  my $self = shift;
  return $self->{_fs} if $self->{_fs};
  $self->{_fs} = FactStore->new('./data/factoids.sqi');
  return $self->{_fs};
}

sub handle {
	my ($self,$event,$responded) = @_;

	if ($event->{alarm} && defined($self->{quiet})) {
		$self->{quiet}-- if $self->{quiet};
		return 0;
	}

	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;
	return if $self->{quiet};

	if ($event->{text} =~ /^$self->{config}->{username}\s*,?\s+(shh+|quiet|shutup|shush|stfu)/i) {
		$self->{quiet} = 60;
		return 0;
	}

	(my $incoming = $event->{text}) =~ s/^\s+|\s+$//g;
	$incoming =~ s/\s\s+/\s/g;
	return if !$incoming;
	my $i_say = $self->factstore->chat($incoming);
	
	if (defined $i_say) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				(split(/\s*\n\s*/,$i_say))[0]
			);
		return "fact, fact, fact";
	}

	return 0;
}

1;

