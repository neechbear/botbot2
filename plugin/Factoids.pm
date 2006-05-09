package plugin::Factoids;
use base plugin;
use strict;
use FactStore;

our $DESCRIPTION = 'InfoBot-like factoid plugin';
our %CMDHELP = (
		'X is Y' => 'Teach botbot that X is Y',
		'X is also Z' => 'Teach botbot that X is also Y',
		'X?' => 'Ask botbot what X is',
		'no, X is A' => 'Tell botbot that X is A and to forget everything it previously knew about X'
	);

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

	if ($event->{text} =~ /^$self->{config}->{username}\s*,?\s+(s+h+|q+u+i+e+t+|s+h+u+[td]+\s*u+p+|s+h+u+s+h+|stfu)/i ||
		$event->{text} =~ /^\s*(s+h+|q+u+i+e+t+|s+h+u+[td]+\s*u+p+|s+h+u+s+h+|stfu)\s*,?\s*$self->{config}->{username}/i) {
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

