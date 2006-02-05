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

	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;

	(my $incoming = $event->{text}) =~ s/^\s+|\s+$//g;
	$incoming =~ s/\s\s+/\s/g;
	return if !$incoming;
	my $i_say = $self->factstore->chat($incoming);
	
	if (defined $i_say) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$i_say
			);
		return "fact, fact, fact";
	}

	return 0;
}

1;

