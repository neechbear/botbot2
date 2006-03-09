package plugin::Cunt;
use base plugin;
use strict;

our $DESCRIPTION = 'Responds to rude words with cunty fliglets';

sub handle {
	my ($self,$event,$responded) = @_;

	return if $event->{alarm};
	return undef unless int(rand(2)) == 1;

	my @words = qw(beaver clit cock cooter cornhole cunt
				douche fuck jizz poontang prick pussy
				queef snatch tits twat fuckhole);

	return unless grep(/^$event->{command}$/i,@words);

	my $data = `figlet $event->{command}`;
	$self->{talker}->whisper(
			($event->{list} ? $event->{list} : $event->{person}),
			" $_"
		) for split(/\n/,$data);

	return "Said a rude word";
}

1;

