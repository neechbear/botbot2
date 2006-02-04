package plugin::Factoids;
use base plugin;
use strict;
use lib "/Users/ti/Documents/tech/ork/factfinder/lib";
use FactStore;

sub factstore {
  my $self = shift;
  return $self->{_fs} if $self->{_fs};
  $self->{_fs} = FactStore->new("data/factoids.sqi");
  return $self->{_fs};
}

sub handle {
	my ($self,$event,$responded) = @_;
	# doesn't work with lists at the mo
	return if $event->{alarm};
	return unless $event->{msgtype} =~ /^OBSERVE TALK|TALK|TELL|LISTTALK$/;
	my $incoming = $event->{text};
	warn "Factoids: I hear $incoming";
	return if !$incoming;
	my $i_say = $self->factstore->chat($incoming);
	
	if (defined $i_say) {
		$self->{talker}->whisper(
				($event->{list} ? $event->{list} : $event->{person}),
				$i_say
			);
	}
	return "fact, fact, fact";
}

1;

